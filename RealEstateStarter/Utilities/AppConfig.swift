//
//  AppConfig.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/18.
//

// Utilities/AppConfig.swift
import Foundation

/// Info.plist（xcconfig置換）から設定を安全に読み出すユーティリティ。
enum AppConfig {
    // MARK: - Public

    static let baseURL: URL = {
        if let s = value("BASE_URL"), let u = URL(string: s), !s.isEmpty { return u }
        return URL(string: "https://your.api.example.com")!   // フォールバック
    }()

    static let useAPI: Bool        = bool("USE_API", default: true)
    static let useFallback: Bool   = bool("USE_FALLBACK", default: true)
    static let logLevel: String    = value("LOG_LEVEL") ?? "WARN"

    /// ネットワークリクエストのタイムアウト（秒）
    static let apiTimeoutSeconds: TimeInterval = {
        if let s = value("API_TIMEOUT_SECONDS"), let sec = TimeInterval(s) { return sec }
        return 15   // フォールバック
    }()

    // MARK: - Private helpers

    private static func value(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    private static func bool(_ key: String, default def: Bool) -> Bool {
        let raw = (value(key) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch raw {
        case "1","true","yes":  return true
        case "0","false","no":  return false
        default:                 return def
        }
    }
}
