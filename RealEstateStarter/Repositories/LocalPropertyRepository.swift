//
//  LocalPropertyRepository.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/16.
//

import Foundation

struct LocalPropertyRepository: PropertyRepository {

    // [修正] 読み込むリソース名を外から差し替えられるように（デフォルト: "properties"）
    //        Resources/properties.json を読む想定です。
    let resourceName: String

    init(resourceName: String = "properties") { // [修正]
        self.resourceName = resourceName        // [修正]
    }

    func fetchProperties() async throws -> [Property] {
        // 既存の PropertyBundleLoader は必須引数 name: を要求するため、明示的に渡します。
        // 多くの実装では "properties"（拡張子なし）で OK ですが、実装によっては
        // "properties.json" を要求する場合があります。もし読み込めない場合は下の
        // 代替行（.json付き）に切り替えてください。

        return try await Task {
            try PropertyBundleLoader.load(name: resourceName) // [修正] ← name を渡す
            // もし実装が拡張子込みを要求するならこちら:
            // try PropertyBundleLoader.load(name: "\(resourceName).json")
        }.value
    }
}
