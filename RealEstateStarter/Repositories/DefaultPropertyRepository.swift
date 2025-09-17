//
//  DefaultPropertyRepository.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// [追加] Repositories/DefaultPropertyRepository.swift
import Foundation

/// APIの結果を優先し、失敗時はローカル（例: Resources/properties.json）へフォールバックするRepository。
struct DefaultPropertyRepository: PropertyRepository {
    // [追加] 依存（DI）
    let baseURL: URL                 // 例: URL(string: "https://your.api.example.com")!
    let apiClient: APIClient         // 例: DefaultAPIClient()
    let local: PropertyRepository    // 例: LocalPropertyRepository()

    // [追加] 任意のデコーダ設定（必要に応じて調整）
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        // APIの日時がISO8601ならここで統一（不要なら外してOK）
        d.dateDecodingStrategy = .iso8601
        return d
    }

    // MARK: - PropertyRepository
    func fetchProperties() async throws -> [Property] {
        do {
            // [追加] 1) エンドポイントを組み立て（必要に応じてパス名を変更）
            // 例: GET https://your.api.example.com/properties
            var ep = Endpoint.get("properties")           // [追加]
            ep.headers["Accept"] = "application/json"     // [追加] 任意
            let req = try ep.urlRequest(baseURL: baseURL) // [追加]

            // [追加] 2) 通信実行
            let (data, response) = try await apiClient.data(for: req)

            // [追加] 3) ステータス検証
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.httpStatus(http.statusCode)
            }

            // [追加] 4) デコード（まずは `[Property]` を直接）
            // APIの形がローカルJSONと同じならこれで通ります。
            if let items = try? decoder.decode([Property].self, from: data) {
                return items
            }

            // [追加] 5) ここでDTOにマッピングしたい場合は、
            // API専用のDTOを用意して `decoder.decode([APIPropertyDTO].self, from: data)`
            // → `dto.map { $0.toDomain() }` のように拡張してください（下にテンプレあり）。
            // 直接デコードに失敗したらフォールバックへ。
            throw NetworkError.decoding(NSError(domain: "decode", code: -1))
        } catch {
            // [追加] 6) フォールバック：ローカルから読み出し
            if let fallback = try? await local.fetchProperties() {
                return fallback
            }
            // [追加] ローカルも失敗した場合は元のエラーを投げる
            throw error
        }
    }
}
