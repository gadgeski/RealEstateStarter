//
//  RealEstateStarterApp.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

/// アプリのエントリポイント。
/// Repository を Default(API優先・失敗時ローカル) に差し替え、ViewModel を注入します。
@main
struct RealEstateStarterApp: App {

    // お気に入りはアプリ全体で共有するため StateObject で保持
    @StateObject private var favoritesStore = FavoritesStore()  // [追加]

    var body: some Scene {
        WindowGroup {
            
            // ============================
            // BASE_URL を Info.plist から取得（xcconfig で外出し推奨）
            // キーが無い/不正でも落ちないようフォールバックを用意
            // ============================
            let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String // [追加]
            let baseURL: URL = {                                                                // [追加]
                if let s = baseURLString, let u = URL(string: s) { return u }
                // フォールバック（検証用）：必要に応じて編集してください
                return URL(string: "https://your.api.example.com")!
            }()

            // ============================
            // Repository を API優先→失敗時ローカル に差し替え
            // 旧: let repository = LocalPropertyRepository()
            // ============================
            let repository = DefaultPropertyRepository(                 // [変更]
                baseURL: baseURL,
                apiClient: DefaultAPIClient(),
                local: LocalPropertyRepository()
            )

            // ============================
            // ViewModel を生成し、View に依存注入
            // ============================
            let viewModel = PropertyListViewModel(repository: repository) // [変更]

            // ルート画面（現状は一覧）。タブ構成にする場合は MainTabView へ差し替え可。
            PropertyListView(viewModel: viewModel)                         // [変更]
                .environmentObject(favoritesStore)                         // [追加] お気に入り共有
        }
    }
}
