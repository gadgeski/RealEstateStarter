//
//  Endpoint.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// [追加] Networking/Endpoint.swift
import Foundation

/// リクエストの基本定義（path / query / method / headers / body）
struct Endpoint {
    enum Method: String { case GET, POST, PUT, PATCH, DELETE }

    var path: String
    var method: Method = .GET
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data? = nil

    /// baseURL と合成して URLRequest を生成
    func urlRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        // baseURL.path に末尾スラッシュが無くても安全に結合
        let basePath = components.path.hasSuffix("/") ? components.path : components.path + "/"
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        components.path = basePath + trimmed

        if !queryItems.isEmpty {
            // 空文字を含むQueryはURLComponentsが落とす場合があるので必要ならエンコード調整
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

// [追加] 便利イニシャライザ（GET用ショートカット）
extension Endpoint {
    static func get(_ path: String, query: [URLQueryItem] = [], headers: [String: String] = [:]) -> Endpoint {
        Endpoint(path: path, method: .GET, queryItems: query, headers: headers, body: nil)
    }
}
