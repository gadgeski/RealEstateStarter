//
//  RealEstateStarterApp.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

@main
struct RealEstateStarterApp: App {
    @StateObject private var favorites = FavoritesStore()   // ★ 追加

    var body: some Scene {
        WindowGroup {
            MainTabView(properties: MockProperties.sample)
                .environmentObject(favorites)              // ★ 注入
        }
    }
}
