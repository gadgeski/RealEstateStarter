//
//  DefaultPropertyRepository.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// Repositories/DefaultPropertyRepository.swift
import Foundation
import CryptoKit   // [追加] 決定論的UUID生成に使用（iOS 13+）

/// API を優先し、失敗時はローカルへフォールバックする Repository。
/// DTO 経由のデコードに加え、IDの安定化・マッピングガードを強化。
struct DefaultPropertyRepository: PropertyRepository {
    // 依存（DI）
    let baseURL: URL
    let apiClient: APIClient
    let local: PropertyRepository

    // 任意のデコーダ設定
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    // MARK: - Public
    func fetchProperties() async throws -> [Property] {
        do {
            // [変更] DTO 経由でフェッチ
            var ep = Endpoint.get("properties")
            ep.headers["Accept"] = "application/json"
            var req = try ep.urlRequest(baseURL: baseURL)
            req.timeoutInterval = AppConfig.apiTimeoutSeconds  // [前提] AppConfig 導入済み

            let (data, response) = try await apiClient.data(for: req)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.httpStatus(http.statusCode)
            }

            // 1) DTO デコード（トップレベルの形に寛容）
            let dtos = try decodeDTOs(from: data)

            // 2) DTO → Domain へ
            let mapped = dtos.compactMap { $0.toDomain() }

            // 3) [追加] マッピング・ガード
            //    「DTOは取れたのに 1件も Domain にできない」= 仕様ズレと判断 → デコード失敗扱いでフォールバック
            if !dtos.isEmpty && mapped.isEmpty {
                #if DEBUG
                print("[DefaultPropertyRepository] Mapping guard triggered: \(dtos.count) DTOs → 0 mapped")
                #endif
                throw NetworkError.decoding(NSError(domain: "mapping", code: -1))
            }

            // 正常
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

    /// トップレベルが [DTO] / {data:[DTO]} / {properties:[DTO]} の3パターンに対応
    private func decodeDTOs(from data: Data) throws -> [APIPropertyDTO] {
        if let arr = try? decoder.decode([APIPropertyDTO].self, from: data) {
            return arr
        }
        if let wrapped = try? decoder.decode(APIListDataWrapper.self, from: data) {
            return wrapped.data
        }
        if let wrapped = try? decoder.decode(APIListPropertiesWrapper.self, from: data) {
            return wrapped.properties
        }
        throw NetworkError.decoding(NSError(domain: "decode", code: -1))
    }
}

// MARK: - DTO とラッパ

/// API の物件DTO（暫定→確定移行期に備え、名称の揺れを一部許容）
private struct APIPropertyDTO: Decodable {
    // ID は文字列想定（数値や他形式でも文字列に載ってくることを想定）
    let id: String?

    // 必須相当
    let title: String?

    // 家賃（名称ゆらぎ）
    let rent: Int?
    let price: Int?
    let monthlyRent: Int?
    let rentYen: Int?

    let layout: String?
    let area: String?
    let nearestStation: String?

    // 徒歩分数（名称ゆらぎ）
    let walkMinutes: Int?
    let walkMin: Int?

    // 画像
    let imageSystemName: String?
    let imageName: String?

    // 位置情報
    let latitude: Double?
    let longitude: Double?

    // 市区町村候補（仕様確定前のゆらぎ吸収）
    let wardOrCity: String?
    let ward: String?
    let city: String?
    let municipality: String?
    let prefecture: String?

    private enum CodingKeys: String, CodingKey {
        case id, title, rent, price, monthlyRent, rentYen
        case layout, area, nearestStation
        case walkMinutes, walkMin
        case imageSystemName, imageName
        case latitude, longitude
        case wardOrCity, ward, city, municipality, prefecture
    }
}

private struct APIListDataWrapper: Decodable {
    let data: [APIPropertyDTO]
}

private struct APIListPropertiesWrapper: Decodable {
    let properties: [APIPropertyDTO]
}

// MARK: - DTO → Domain 変換（ガード強化）

private extension APIPropertyDTO {
    func toDomain() -> Property? {
        // 必須: title
        guard let rawTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawTitle.isEmpty else { return nil }

        // 家賃：異常値ガード（負値→0）
        let rawRent = rent ?? price ?? monthlyRent ?? rentYen ?? 0
        let rentValue = max(0, rawRent) // [追加] 0未満は0へ

        // 徒歩分数：異常値は0に丸め
        let walkValue = max(0, walkMinutes ?? walkMin ?? 0)

        // 画像：無ければ house.fill
        let image = imageSystemName ?? imageName ?? "house.fill"

        // 表示用デフォルト
        let layoutValue = (layout?.isEmpty == false) ? layout! : "1K"
        let areaValue = (area?.isEmpty == false) ? area! : "—"
        let stationValue = (nearestStation?.isEmpty == false) ? nearestStation! : "—"

        // 市区町村の決定（DTO→推定の順）
        let wardOrCityValue: String = {
            if let s = wardOrCity, !s.isEmpty { return s }
            if let s = ward, !s.isEmpty { return s }
            if let s = city, !s.isEmpty { return s }
            if let s = municipality, !s.isEmpty { return s }
            // area から簡易抽出（「〜区」「〜市」「〜町」「〜村」）
            let tokens = areaValue.split { $0 == " " || $0 == "　" }
            if let token = tokens.first(where: { $0.hasSuffix("区") || $0.hasSuffix("市") || $0.hasSuffix("町") || $0.hasSuffix("村") }) {
                return String(token)
            }
            return areaValue
        }()

        // [変更] ID の安定化：
        // - APIがUUID文字列ならそれを優先
        // - UUIDでない/空なら、「安定種」から決定論的UUIDを生成（ハッシュ）
        let uuid: UUID = {
            if let s = id?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
                if let asUUID = UUID(uuidString: s) { return asUUID }
                // UUIDでなくても、APIのid文字列が安定していれば安定UUIDへ変換
                return Self.deterministicUUID(from: "id:\(s)")
            } else {
                // 文字列IDすら無ければ、物件の特徴から安定UUIDを生成
                let seed = "title:\(rawTitle)|area:\(areaValue)|station:\(stationValue)|ward:\(wardOrCityValue)|layout:\(layoutValue)|rent:\(rentValue)"
                return Self.deterministicUUID(from: seed)
            }
        }()

        return Property(
            id: uuid,
            title: rawTitle,
            rent: rentValue,
            layout: layoutValue,
            area: areaValue,
            wardOrCity: wardOrCityValue,
            nearestStation: stationValue,
            walkMinutes: walkValue,
            imageSystemName: image,
            latitude: latitude,
            longitude: longitude
        )
    }

    // [追加] 文字列から決定論的にUUIDを生成（SHA256の先頭16バイトを使用）
    private static func deterministicUUID(from string: String) -> UUID {
        let digest = SHA256.hash(data: Data(string.utf8))
        var bytes = Array(digest) // 32 bytes
        // RFC準拠の体裁を整える（version=4 / variant=RFC4122 っぽく）
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        let a = Array(bytes[0..<16])
        // UUID(uuid:) は16バイトのタプルが必要
        return UUID(uuid: (a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12], a[13], a[14], a[15]))
    }
}
