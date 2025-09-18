//
//  DefaultPropertyRepository.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// Repositories/DefaultPropertyRepository.swift
import Foundation

/// API を優先し、失敗時はローカルへフォールバックする Repository。
/// 直デコード([Property])から DTO 経由のデコードに変更し、
/// 不足値に安全なデフォルト／`wardOrCity` の推定を追加。
struct DefaultPropertyRepository: PropertyRepository {
    // 依存（DI）
    let baseURL: URL
    let apiClient: APIClient
    let local: PropertyRepository

    // 任意のデコーダ設定
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase // [追加] snake_case にも寛容
        return d
    }

    // MARK: - Public
    func fetchProperties() async throws -> [Property] {
        do {
            // [変更] DTO 経由でデコード（パス名は必要に応じて変更）
            var ep = Endpoint.get("properties")
            ep.headers["Accept"] = "application/json"
            var req = try ep.urlRequest(baseURL: baseURL)

            // [追加] タイムアウト（AppConfig がある前提。無いならこの1行はコメントアウト可）
            req.timeoutInterval = AppConfig.apiTimeoutSeconds

            let (data, response) = try await apiClient.data(for: req)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.httpStatus(http.statusCode)
            }

            // [変更] フレキシブルなトップレベルに対応して DTO を取得
            let dtos = try decodeDTOs(from: data)

            // [変更] DTO → Domain へマッピング（不足値は安全なデフォルト）
            let mapped = dtos.compactMap { $0.toDomain() }
            return mapped
        } catch {
            // [変更] 失敗時はローカルへフォールバック
            if let fallback = try? await local.fetchProperties() {
                return fallback
            }
            throw error
        }
    }

    // MARK: - Decode helpers

    /// [追加] トップレベルが [DTO] / {data:[DTO]} / {properties:[DTO]} の3パターンに対応
    private func decodeDTOs(from data: Data) throws -> [APIPropertyDTO] {
        // 1) 素の配列
        if let arr = try? decoder.decode([APIPropertyDTO].self, from: data) {
            return arr
        }
        // 2) { "data": [...] }
        if let wrapped = try? decoder.decode(APIListDataWrapper.self, from: data) {
            return wrapped.data
        }
        // 3) { "properties": [...] }
        if let wrapped = try? decoder.decode(APIListPropertiesWrapper.self, from: data) {
            return wrapped.properties
        }
        // 4) どれでもない → デコードエラー
        throw NetworkError.decoding(NSError(domain: "decode", code: -1))
    }
}

// MARK: - [追加] DTO とラッパ

/// API の物件DTO（API差異に耐えるよう、複数別名を許容）
private struct APIPropertyDTO: Decodable {
    // ID（文字列想定。数値が来るAPIなら later: カスタムデコードに差し替え）
    let id: String?

    // 必須相当（title が無いものは toDomain() で捨てる）
    let title: String?

    // 家賃：別名に寛容
    let rent: Int?
    let price: Int?
    let monthlyRent: Int?
    let rentYen: Int?

    let layout: String?
    let area: String?
    let nearestStation: String?

    // 徒歩分数：別名に寛容
    let walkMinutes: Int?
    let walkMin: Int?

    // 画像（無ければデフォルト）
    let imageSystemName: String?
    let imageName: String?

    // 位置情報（任意）
    let latitude: Double?
    let longitude: Double?

    // [追加] 市区町村系：API差異に対応（どれかが来ればOK）
    let wardOrCity: String?
    let ward: String?
    let city: String?
    let municipality: String?
    let prefecture: String? // 参考用（推定の補助）

    private enum CodingKeys: String, CodingKey {
        case id, title, rent, price, monthlyRent, rentYen
        case layout, area, nearestStation
        case walkMinutes, walkMin
        case imageSystemName, imageName
        case latitude, longitude
        case wardOrCity, ward, city, municipality, prefecture // [追加]
    }
}

/// { "data": [ ... ] }
private struct APIListDataWrapper: Decodable {
    let data: [APIPropertyDTO]
}

/// { "properties": [ ... ] }
private struct APIListPropertiesWrapper: Decodable {
    let properties: [APIPropertyDTO]
}

// MARK: - [追加] DTO → Domain 変換

private extension APIPropertyDTO {
    /// 必須最低限: title が無ければ捨てる。その他は安全なデフォルトを適用。
    func toDomain() -> Property? {
        // title が無ければ不可
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            return nil
        }

        // 家賃：候補のうち最初に見つかったもの。無ければ 0。
        let rentValue = rent ?? price ?? monthlyRent ?? rentYen ?? 0

        // 徒歩分数：無ければ 0
        let walk = walkMinutes ?? walkMin ?? 0

        // 画像：無ければ house.fill
        let image = imageSystemName ?? imageName ?? "house.fill"

        // UUID：String を優先。変換不可なら新規生成。
        let uuid: UUID = {
            if let id, let u = UUID(uuidString: id) { return u }
            return UUID()
        }()

        // 表示安全なデフォルト
        let layoutValue = (layout?.isEmpty == false) ? layout! : "1K"
        let areaValue = (area?.isEmpty == false) ? area! : "—"
        let stationValue = (nearestStation?.isEmpty == false) ? nearestStation! : "—"

        // [追加] wardOrCity を DTO から or area から推定
        let wardOrCityValue: String = {
            // 1) 明示キーがあればそれを使う
            if let s = wardOrCity, !s.isEmpty { return s }
            if let s = ward, !s.isEmpty { return s }
            if let s = city, !s.isEmpty { return s }
            if let s = municipality, !s.isEmpty { return s }
            // 2) area から簡易抽出（「渋谷区」「世田谷区」「横浜市」など）
            //    area が「東京都 渋谷区 恵比寿…」のような場合、空白で分割して
            //    「〜区」「〜市」「〜町」「〜村」で終わる最初のトークンを採用
            let tokens = areaValue.split { $0 == " " || $0 == "　" }
            if let token = tokens.first(where: { $0.hasSuffix("区") || $0.hasSuffix("市") || $0.hasSuffix("町") || $0.hasSuffix("村") }) {
                return String(token)
            }
            // 3) 何も拾えなければ area をそのまま（"—" になることもあり得る）
            return areaValue
        }()

        // Domain へ
        return Property(
            id: uuid,
            title: title,
            rent: rentValue,
            layout: layoutValue,
            area: areaValue,
            wardOrCity: wardOrCityValue,        // [追加] 必須引数を渡す
            nearestStation: stationValue,
            walkMinutes: walk,
            imageSystemName: image,
            latitude: latitude,
            longitude: longitude
        )
    }
}
