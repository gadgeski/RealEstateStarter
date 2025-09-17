//
//  APIClient.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// [追加] Networking/APIClient.swift
import Foundation

/// URLSessionを薄く抽象化（テスト容易性＆差し替え用）
protocol APIClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct DefaultAPIClient: APIClient {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch {
            throw NetworkError.transport(error)
        }
    }
}

// [追加] デコードのユーティリティ（必要時に任意で使用）
extension APIClient {
    func decodable<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> (T, URLResponse) {
        let (data, response) = try await data(for: request)
        do {
            let value = try decoder.decode(T.self, from: data)
            return (value, response)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}
