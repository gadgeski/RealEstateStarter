//
//  PropertyListView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct PropertyListView: View {
    // ============================
    // [変更] 旧: let properties: [Property]
    // ViewModel を注入（Step5で導入済み）
    // ============================
    @StateObject var viewModel: PropertyListViewModel

    @State private var filter = PropertyFilter()
    @State private var isFilterPresented = false
    @EnvironmentObject private var favorites: FavoritesStore

    // ============================
    // [削除] 旧: lastRefreshed（@State）
    // 画面側の時刻管理を廃止し、ViewModel の lastUpdated を使用
    // ============================

    // [追加] 既存コード互換：viewModel.properties を参照するブリッジ
    private var properties: [Property] { viewModel.properties }

    // 家賃の最小・最大（フィルタシートの範囲用）
    private var rentBounds: ClosedRange<Int> {
        let rents = properties.map(\.rent)
        guard let min = rents.min(), let max = rents.max(), min <= max else {
            return 50_000...300_000
        }
        return min...max
    }

    // エリア候補（ユニーク & ソート）
    private var availableAreas: [String] {
        Array(Set(properties.map(\.wardOrCity))).sorted()
    }

    // ============================
    // [変更] 更新時刻の表示テキストを ViewModel の lastUpdated から生成
    // ============================
    private var updatedText: String? {
        guard let t = viewModel.lastUpdated else { return nil }
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP_POSIX")
        df.dateFormat = "HH:mm"
        return "更新: \(df.string(from: t))"
    }

    // フィルタ要約テキスト（“何件・どの条件か”）
    private var activeFilterSummary: String {
        var parts: [String] = []
        if !filter.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("検索: \(filter.query)")
        }
        if let m = filter.maxRent {
            parts.append("家賃 ≤ \(m.formatted(.currency(code: "JPY")))")
        }
        if let w = filter.maxWalkMinutes {
            parts.append("徒歩 ≤ \(w)分")
        }
        if !filter.selectedAreas.isEmpty {
            parts.append(filter.selectedAreas.sorted().joined(separator: "・"))
        }
        parts.append("\(filtered.count)件")
        if let txt = updatedText { parts.append(txt) } // [変更] lastUpdated を表示
        return parts.joined(separator: " / ")
    }

    // フィルタ＆検索適用済みの一覧
    private var filtered: [Property] {
        let q = filter.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base = properties.filter { p in
            // テキスト検索（物件名・エリア・駅名）
            let haystack = "\(p.title) \(p.area) \(p.nearestStation)".lowercased()
            let matchesQuery = q.isEmpty || haystack.contains(q)
            // 家賃上限
            let matchesRent = filter.maxRent.map { p.rent <= $0 } ?? true
            // 徒歩分数上限
            let matchesWalk = filter.maxWalkMinutes.map { p.walkMinutes <= $0 } ?? true
            // エリア一致（未選択=全許可）
            let matchesArea = filter.selectedAreas.isEmpty || filter.selectedAreas.contains(p.wardOrCity)
            return matchesQuery && matchesRent && matchesWalk && matchesArea
        }
        // 並び替え
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
                // ここが「List の前」＝常時表示の要約バー
                Text(activeFilterSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // ローディング／エラー／通常 の三分岐
                if viewModel.isLoading && properties.isEmpty {
                    ProgressView("読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                } else if let message = viewModel.errorMessage, properties.isEmpty {
                    VStack(spacing: 12) {
                        Text("データ取得に失敗しました").font(.headline)
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("再試行") {
                            // [変更] 非同期版 reload を呼び出し（Button内なので Task でラップ）
                            Task { await viewModel.reload() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()

                } else if filtered.isEmpty {
                    ContentUnavailableView(
                        "該当する物件がありません",
                        systemImage: "magnifyingglass",
                        description: Text("検索条件や絞り込みを見直してください。")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                } else {
                    List(filtered) { property in
                        NavigationLink(value: property) {
                            PropertyRow(property: property)
                        }
                        // 行のスワイプでお気に入りトグル
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
                    // ============================
                    // [変更] プル・トゥ・リフレッシュを async 版に統一
                    // 旧: .refreshable { await refresh() } / 旧: viewModel.load()
                    // ============================
                    .refreshable {
                        await viewModel.reload()
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
            .toolbar {
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
        // ============================
        // [変更] 初回ロードのみ実行（時刻は ViewModel 側が更新）
        // ============================
        .task {
            if properties.isEmpty {
                viewModel.load()
            }
        }
    }

    // ============================
    // [削除] 旧: refresh() は不要（ViewModel.reload() に統一）
    // ============================
}

#Preview {
    struct PreviewRepo: PropertyRepository {
        func fetchProperties() async throws -> [Property] {
            MockProperties.sample
        }
    }
    let vm = PropertyListViewModel(repository: PreviewRepo())
    return PropertyListView(viewModel: vm)
        .environmentObject(FavoritesStore())
}
