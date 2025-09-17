//
//  NetworkError.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/17.
//

// [追加] Networking/NetworkError.swift
import Foundation

/// ネットワーク層で共通利用するエラー型
enum NetworkError: Error, LocalizedError {
    case invalidURL                       // URL生成に失敗
    case invalidResponse                  // URLResponseの型や基本検証に失敗
    case httpStatus(Int)                  // 2xx以外のHTTPステータス
    case decoding(Error)                  // JSONデコード失敗
    case transport(Error)                 // URLSessionなど下位からのエラー

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです。"
        case .invalidResponse:
            return "不正なレスポンスです。"
        case .httpStatus(let code):
            return "HTTPステータスエラー (\(code))。"
        case .decoding(let err):
            return "デコードに失敗しました: \(err.localizedDescription)"
        case .transport(let err):
            return "通信エラーが発生しました: \(err.localizedDescription)"
        }
    }
}
