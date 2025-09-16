//
//  MainTabView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct MainTabView: View {
    // 既存：呼び出し元の API を壊さないため、そのまま受け取る
    let properties: [Property]

    // ============================
    // [追加] PropertyRepository の簡易実装（固定の配列を返す）
    // これで “配列 → ViewModel” へブリッジできます
    // ============================
    private struct SnapshotRepo: PropertyRepository {
        let snapshot: [Property]
        func fetchProperties() async throws -> [Property] { snapshot }
    }

    // ============================
    // [追加] タブ内で使い回す ViewModel を1つ用意
    // `let` にして再生成を防ぎます（PropertyListView 側が @StateObject 保持）
    // ============================
    private let listViewModel: PropertyListViewModel  // [追加]

    // ============================
    // [追加] カスタム init：
    // 渡された配列から SnapshotRepo → ViewModel を組み立てる
    // ============================
    init(properties: [Property]) {                     // [追加]
        self.properties = properties                   // [追加]
        let repo = SnapshotRepo(snapshot: properties)  // [追加]
        self.listViewModel = PropertyListViewModel(repository: repo) // [追加]
    }

    var body: some View {
        TabView {
            // 物件一覧タブ
            // ============================
            // [変更] 配列ではなく ViewModel を渡す
            // 旧: PropertyListView(properties: properties)
            // ============================
            PropertyListView(viewModel: listViewModel) // [変更]
                .tabItem {
                    Label("物件", systemImage: "list.bullet")
                }

            // （任意）他タブがある場合はそのまま残してOK
            // 例:
            // FavoritesListView()
            //     .tabItem { Label("お気に入り", systemImage: "star") }
            //
            // SettingsView()
            //     .tabItem { Label("設定", systemImage: "gearshape") }
            //
            // MapExploreView() など、もし properties を必要とするなら
            // 同様の手法で “ブリッジ用 ViewModel / Repository” を用意すると安全です。
        }
    }
}

#Preview {
    // プレビュー：モックデータ＋お気に入りストア
    MainTabView(properties: MockProperties.sample)
        .environmentObject(FavoritesStore())
}
