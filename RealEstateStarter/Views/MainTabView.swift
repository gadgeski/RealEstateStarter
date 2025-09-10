//
//  MainTabView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct MainTabView: View {
    let properties: [Property]

    var body: some View {
        TabView {
            // 物件一覧（既存画面そのまま利用）
            PropertyListView(properties: properties)
                .tabItem {
                    Label("物件", systemImage: "list.bullet")
                }

            // 地図タブ
            MapExploreView(properties: properties)
                .tabItem {
                    Label("地図", systemImage: "map")
                }

            // 設定タブ
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView(properties: MockProperties.sample)
}
