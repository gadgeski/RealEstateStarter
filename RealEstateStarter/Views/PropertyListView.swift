//
//  PropertyListView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct PropertyListView: View {
    @StateObject var viewModel: PropertyListViewModel

    @State private var filter = PropertyFilter()
    @State private var isFilterPresented = false
    @EnvironmentObject private var favorites: FavoritesStore

    // [追加] 並び替え表示テキスト
    private var sortLabel: String {
        switch filter.sort {
        case .rentAsc:  return "家賃↑"
        case .rentDesc: return "家賃↓"
        case .walkAsc:  return "徒歩↑"
        case .walkDesc: return "徒歩↓"
        }
    }

    // [変更] 件数＋更新時刻（相対表現）
    private var updatedText: String? {
        guard let t = viewModel.lastUpdated else { return nil }
        let f = RelativeDateTimeFormatter(); f.locale = .init(identifier: "ja_JP")
        return f.localizedString(for: t, relativeTo: .now) // 例) “5分前”
    }

    // 既存：VMの配列を参照
    private var properties: [Property] { viewModel.properties }

    private var rentBounds: ClosedRange<Int> {
        let rents = properties.map(\.rent)
        guard let min = rents.min(), let max = rents.max(), min <= max else {
            return 50_000...300_000
        }
        return min...max
    }

    private var availableAreas: [String] {
        Array(Set(properties.map(\.wardOrCity))).sorted()
    }

    // フィルタ適用後
    private var filtered: [Property] {
        let q = filter.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base = properties.filter { p in
            let haystack = "\(p.title) \(p.area) \(p.nearestStation)".lowercased()
            let matchesQuery = q.isEmpty || haystack.contains(q)
            let matchesRent = filter.maxRent.map { p.rent <= $0 } ?? true
            let matchesWalk = filter.maxWalkMinutes.map { p.walkMinutes <= $0 } ?? true
            let matchesArea = filter.selectedAreas.isEmpty || filter.selectedAreas.contains(p.wardOrCity)
            return matchesQuery && matchesRent && matchesWalk && matchesArea
        }
        return base.sorted { a, b in
            switch filter.sort {
            case .rentAsc:  return a.rent < b.rent
            case .rentDesc: return a.rent > b.rent
            case .walkAsc:  return a.walkMinutes < b.walkMinutes
            case .walkDesc: return a.walkMinutes > b.walkMinutes
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 6) {

                // ============================
                // [追加] 要約バーを“チップ化”して視認性UP
                //  - 左: 件数チップ
                //  - 右: 並び替えチップ（タップでメニュー）
                //  - 更新時刻（相対）も末尾に
                // ============================
                HStack {
                    // 件数チップ
                    Chip(text: "\(filtered.count)件", systemImage: "list.number")
                        .accessibilityLabel("該当件数 \(filtered.count) 件")

                    Spacer(minLength: 8)

                    // 並び替えメニュー（チップ）
                    Menu {
                        Button("家賃（安い順）", systemImage: "arrow.down") { filter.sort = .rentAsc }
                        Button("家賃（高い順）", systemImage: "arrow.up")   { filter.sort = .rentDesc }
                        Divider()
                        Button("徒歩（短い順）", systemImage: "arrow.down") { filter.sort = .walkAsc }
                        Button("徒歩（長い順）", systemImage: "arrow.up")   { filter.sort = .walkDesc }
                    } label: {
                        Chip(text: "並び: \(sortLabel)", systemImage: "arrow.up.arrow.down") // [追加]
                    }
                    .accessibilityLabel("並び替え")
                }
                .padding(.horizontal)
                .padding(.top, 4)

                // 更新時刻（相対）
                if let u = updatedText {
                    Text("最終更新 \(u)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }

                // ===== リスト表示/エラー/空表示 =====
                if viewModel.isLoading && properties.isEmpty {
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                } else if let message = viewModel.errorMessage, properties.isEmpty {
                    // ============================
                    // [変更] エラー時の“次アクション”を強化
                    //  - 再試行（自動フォールバック込み）
                    //  - フィルタをリセット（ネット復旧後の0件/条件過多に備えて）
                    // ============================
                    VStack(spacing: 12) {
                        ContentUnavailableView(
                            "データ取得に失敗しました",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                        HStack(spacing: 12) {
                            Button {
                                Task { await viewModel.reload() }    // 再試行
                            } label: {
                                Label("再試行", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.borderedProminent)

                            Button(role: .destructive) {
                                filter = PropertyFilter()             // [追加] 条件リセット
                            } label: {
                                Label("条件をリセット", systemImage: "xmark.circle")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()

                } else if filtered.isEmpty {
                    // [変更] 0件時にもアクションを提示
                    VStack(spacing: 12) {
                        ContentUnavailableView(
                            "該当する物件がありません",
                            systemImage: "magnifyingglass",
                            description: Text("検索条件や絞り込みを見直してください。")
                        )
                        HStack(spacing: 12) {
                            Button {
                                filter = PropertyFilter()             // [追加] 条件リセット
                            } label: {
                                Label("条件をリセット", systemImage: "xmark.circle")
                            }
                            .buttonStyle(.bordered)

                            Button {
                                isFilterPresented = true              // [追加] 絞り込みを開く
                            } label: {
                                Label("条件を調整", systemImage: "slider.horizontal.3")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()

                } else {
                    List(filtered) { property in
                        NavigationLink(value: property) {
                            PropertyRow(property: property)           // [変更] 価格強調版を使用
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            let isFav = favorites.isFavorite(property)
                            Button {
                                favorites.toggle(property)
                            } label: {
                                Label(isFav ? "外す" : "追加", systemImage: "star")
                            }
                            .tint(isFav ? .gray : .yellow)
                            .accessibilityLabel(isFav ? "お気に入りから外す" : "お気に入りに追加")
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.reload()                      // [変更] 統一
                    }
                }
            }
            .navigationTitle("物件一覧")
            .scrollDismissesKeyboard(.interactively)
            .searchable(
                text: $filter.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "駅名・エリア・物件名"
            )
            // [追加] ツールバーにも“並び替え”を置く（片手操作向け）
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("並び替え", selection: $filter.sort) {
                            Text("家賃（安→高）").tag(PropertyFilter.Sort.rentAsc)
                            Text("家賃（高→安）").tag(PropertyFilter.Sort.rentDesc)
                            Text("徒歩（短→長）").tag(PropertyFilter.Sort.walkAsc)
                            Text("徒歩（長→短）").tag(PropertyFilter.Sort.walkDesc)
                        }
                    } label: {
                        Label("並び替え", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isFilterPresented.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("絞り込み")
                }
            }
            .navigationDestination(for: Property.self) { property in
                PropertyDetailView(property: property)
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                PropertyFilterSheet(
                    filter: $filter,
                    rentRange: rentBounds,
                    areas: availableAreas
                )
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            if properties.isEmpty {
                viewModel.load() // 初回ロード
            }
        }
    }
}

// [追加] 小さな“チップ”UI（件数や並びを見やすく）
private struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            if let name = systemImage {
                Image(systemName: name)
            }
            Text(text)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.secondary.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    struct PreviewRepo: PropertyRepository {
        func fetchProperties() async throws -> [Property] { MockProperties.sample }
    }
    let vm = PropertyListViewModel(repository: PreviewRepo())
    return PropertyListView(viewModel: vm)
        .environmentObject(FavoritesStore())
}
