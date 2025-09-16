//
//  RealEstateStarterApp.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

@main
struct RealEstateStarterApp: App {
    var body: some Scene {
        WindowGroup {
            // ============================
            // [追加] Repository と ViewModel を生成して注入
            // ============================
            let repository = LocalPropertyRepository() // [追加] まずはローカルJSON実装
            let viewModel = PropertyListViewModel(repository: repository) // [追加] 依存注入

            // ============================
            // [変更] 直接 ViewModel を受け取る PropertyListView を起動
            // 旧: PropertyListView(properties: MockProperties.sample)
            // ============================
            PropertyListView(viewModel: viewModel) // [変更]
        }
    }
}
