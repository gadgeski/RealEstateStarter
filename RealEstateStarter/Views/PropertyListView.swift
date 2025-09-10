//
//  PropertyListView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct PropertyListView: View {
    let properties: [Property]

    @State private var filter = PropertyFilter()
    @State private var isFilterPresented = false
    @EnvironmentObject private var favorites: FavoritesStore   // 既存：お気に入りStore

    // ★ 追加: 最終リフレッシュ時刻（将来のAPI更新日時にも利用）
    @State private var lastRefreshed: Date? = nil

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

    // ★ 追加: リフレッシュ時刻の表示テキスト（任意）
    private var refreshedText: String? {
        guard let t = lastRefreshed else { return nil }
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
        if let refreshed = refreshedText {
            parts.append(refreshed) // ★ 追加: 直近の更新時刻を要約に表示（任意）
        }
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

                if filtered.isEmpty {
                    ContentUnavailableView(
                        "該当する物件がありません",
                        systemImage: "magnifyingglass",
                        description: Text("検索条件や絞り込みを見直してください。")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    // ★ 追加: 空表示時も引っ張って更新できるようにするなら、
                    // ScrollView でラップして .refreshable を付ける実装に変更可。
                } else {
                    List(filtered) { property in
                        NavigationLink(value: property) {
                            PropertyRow(property: property)
                        }
                        // 既存：行のスワイプでお気に入りトグル
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
                    // ★ 追加: プル・トゥ・リフレッシュ
                    .refreshable {
                        await refresh() // 将来: ここでAPIフェッチに差し替え
                    }
                }
            }
            .navigationTitle("物件一覧")
            .scrollDismissesKeyboard(.interactively) // 既存: 検索時のキーボードを自然に格納
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
        // ★ 追加: 画面初期表示時に一度だけ“更新時刻”をセット（任意）
        .task {
            if lastRefreshed == nil {
                lastRefreshed = Date()
            }
        }
    }

    // MARK: - ★ 追加: リフレッシュ処理（将来API時にも流用）

    /// データを再取得する処理。今はダミー待機→時刻更新のみ。
    /// 将来は Repository 経由でフェッチし、@State のデータに反映させる想定。
    @MainActor
    private func refresh() async {
        // ダミーのネットワーク遅延
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        // 【将来】ここで: await repository.fetch(query: …) → @State に反映
        // 現状は外から渡された `properties`（let）なのでデータは変えず、更新時刻のみ更新
        lastRefreshed = Date()
    }
}

#Preview {
    PropertyListView(properties: MockProperties.sample)
        .environmentObject(FavoritesStore())
}
