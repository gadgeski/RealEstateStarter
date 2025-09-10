//
//  PropertyBundleLoader.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation

// ★ 追加: Bundle内の JSON から [Property] を読み込むユーティリティ
enum PropertyBundleLoader {
    struct LoadError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    /// 例: name = "properties"（拡張子は .json 固定）
    static func load(name: String) throws -> [Property] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw LoadError(message: "JSONファイルが見つかりません: \(name).json（Copy Bundle Resourcesに含めてください）")
        }
        let data = try Data(contentsOf: url)
        let dec = JSONDecoder()
        // キーはコード側と同名（lowerCamel）前提。異なる場合はここでstrategyやCodingKeys調整。
        return try dec.decode([Property].self, from: data)
    }
}
