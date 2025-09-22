//
//  FavoritesListView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct FavoritesListView: View {
    let properties: [Property]
    @EnvironmentObject private var favorites: FavoritesStore

    // ★ 追加: 並び替え状態
    @State private var sort: Sort = .rentAsc
    enum Sort: String, CaseIterable, Identifiable {
        case rentAsc, rentDesc, walkAsc, walkDesc, titleAsc
        var id: Self { self }
        var label: String {
            switch self {
            case .rentAsc:  return "家賃 ↑"
            case .rentDesc: return "家賃 ↓"
            case .walkAsc:  return "徒歩 ↑"
            case .walkDesc: return "徒歩 ↓"
            case .titleAsc: return "物件名 A→Z"
            }
        }
    }

    // お気に入りに入っている Property（未ソート）
    // 置き換え
    private var favs: [Property] {
        properties.filter { favorites.isFavorite(id: $0.id) }
        // または: properties.filter { favorites.isFavorite($0) }
    }
    // ★ 追加: 並び替え適用済み
    private var favsSorted: [Property] {
        favs.sorted { a, b in
            switch sort {
            case .rentAsc:  return a.rent < b.rent
            case .rentDesc: return a.rent > b.rent
            case .walkAsc:  return a.walkMinutes < b.walkMinutes
            case .walkDesc: return a.walkMinutes > b.walkMinutes
            case .titleAsc: return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
            }
        }
    }

    // ★ 追加: エクスポート用
    @State private var shareURL: URL? = nil
    @State private var isSharePresented = false
    @State private var exportError: String? = nil

    var body: some View {
        NavigationStack {
            Group {
                if favsSorted.isEmpty {
                    ContentUnavailableView(
                        "お気に入りはまだありません",
                        systemImage: "star",
                        description: Text("詳細画面の⭐︎ボタンや一覧のスワイプで追加できます。")
                    )
                } else {
                    List(favsSorted) { p in
                        NavigationLink(value: p) {
                            PropertyRow(property: p)
                        }
                        // ★ 追加: スワイプでお気に入りから外す
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                favorites.toggle(p) // 外す
                            } label: {
                                Label("外す", systemImage: "star.slash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("お気に入り")
            // ★ 追加: 並び替え & エクスポートのツールバー
            .toolbar {
                // 並び替えメニュー
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("並び替え", selection: $sort) {
                            ForEach(Sort.allCases) { s in
                                Text(s.label).tag(s)
                            }
                        }
                    } label: {
                        Label("並び替え", systemImage: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("並び替え")
                }

                // エクスポートメニュー
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportCSV()
                        } label: {
                            Label("CSVを書き出して共有", systemImage: "square.and.arrow.up")
                        }
                        .disabled(favsSorted.isEmpty)

                        Button {
                            exportJSON()
                        } label: {
                            Label("JSONを書き出して共有", systemImage: "square.and.arrow.up.on.square")
                        }
                        .disabled(favsSorted.isEmpty)
                    } label: {
                        Label("エクスポート", systemImage: "tray.and.arrow.up")
                    }
                    .accessibilityLabel("エクスポート")
                }
            }
            .navigationDestination(for: Property.self) { p in
                PropertyDetailView(property: p)
            }
        }
        // ★ 追加: 共有シート表示
        .sheet(isPresented: $isSharePresented) {
            if let url = shareURL {
                ShareSheet(items: [url]) // UIKitの共有パネル
            }
        }
        // ★ 追加: エラーアラート
        .alert("エクスポートに失敗しました", isPresented: Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        ), actions: {}, message: {
            Text(exportError ?? "")
        })
    }

    // MARK: - エクスポート（CSV/JSON）

    // ★ 追加: CSV書き出し
    private func exportCSV() {
        do {
            let csv = FavoritesExporter.csv(from: favsSorted)
            let url = try FavoritesExporter.writeTempFile(
                named: "favorites_\(timestamp()).csv",
                contents: Data(csv.utf8)
            )
            shareURL = url
            isSharePresented = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    // ★ 追加: JSON書き出し
    private func exportJSON() {
        do {
            let data = try FavoritesExporter.json(from: favsSorted)
            let url = try FavoritesExporter.writeTempFile(
                named: "favorites_\(timestamp()).json",
                contents: data
            )
            shareURL = url
            isSharePresented = true
        } catch {
            exportError = error.localizedDescription
        }
    }

    // ★ 追加: タイムスタンプ（ファイル名用）
    private func timestamp() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP_POSIX")
        df.dateFormat = "yyyyMMdd_HHmm"
        return df.string(from: Date())
    }
}

#Preview {
    FavoritesListView(properties: MockProperties.sample)
        .environmentObject(FavoritesStore())
}
