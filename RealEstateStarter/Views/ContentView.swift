//
//  ContentView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct ContentView: View {
    // ★ 変更: Bundle JSON シナリオを追加
    enum Scenario: String, CaseIterable, Identifiable {
        case empty, minimal, sample20, randomN, bundleJSON // ★ 追加
        var id: Self { self }
        var label: String {
            switch self {
            case .empty:     return "空"
            case .minimal:   return "最小(4)"
            case .sample20:  return "サンプル20"
            case .randomN:   return "ランダムN"
            case .bundleJSON:return "Bundle JSON" // ★ 追加
            }
        }
    }

    @State private var scenario: Scenario = .sample20
    @State private var randomCount: Int = 50
    @State private var bundleFileName: String = "properties" // ★ 追加: "properties.json" を想定
    @State private var bundleLoadError: String? = nil        // ★ 追加: エラー表示用

    @EnvironmentObject private var favorites: FavoritesStore

    // 現在のデータセット
    private var currentProperties: [Property] {
        switch scenario {
        case .empty:
            return []
        case .minimal:
            return Array(MockProperties.sample.prefix(4))
        case .sample20:
            return MockProperties.sample
        case .randomN:
            return RandomMock.properties(count: randomCount)
        case .bundleJSON:
            do {
                return try PropertyBundleLoader.load(name: bundleFileName) // ★ 追加: JSONを読み込み
            } catch {
                // ★ 追加: 失敗時は空配列で表示しつつ上部にエラーを出す
                DispatchQueue.main.async { self.bundleLoadError = error.localizedDescription }
                return []
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            DebugPanel(
                scenario: $scenario,
                randomCount: $randomCount,
                bundleFileName: $bundleFileName,      // ★ 追加
                bundleLoadError: $bundleLoadError,    // ★ 追加
                totalCount: currentProperties.count,
                favoritesCount: favoritesCount(in: currentProperties)
            )
            .padding(.horizontal)
            .padding(.top, 8)

            Divider()

            MainTabView(properties: currentProperties)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func favoritesCount(in properties: [Property]) -> Int {
        properties.filter { favorites.contains($0.id) }.count
    }
}

// ★ 変更: デバッグパネルに「Bundle JSON」入力を追加
private struct DebugPanel: View {
    @Binding var scenario: ContentView.Scenario
    @Binding var randomCount: Int
    @Binding var bundleFileName: String          // ★ 追加
    @Binding var bundleLoadError: String?        // ★ 追加
    let totalCount: Int
    let favoritesCount: Int

    @State private var expanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("デバッグ・パネル").font(.headline)
                Spacer()
                Button {
                    withAnimation { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(expanded ? "折りたたむ" : "展開する")
            }

            if expanded {
                Picker("データセット", selection: $scenario) {
                    ForEach(ContentView.Scenario.allCases) { s in
                        Text(s.label).tag(s)
                    }
                }
                .pickerStyle(.segmented)

                if scenario == .randomN {
                    HStack {
                        Text("件数: \(randomCount)")
                        Spacer()
                        Stepper(value: $randomCount, in: 20...500, step: 10) { EmptyView() }
                            .labelsHidden()
                    }
                }

                // ★ 追加: Bundle JSON 入力欄
                if scenario == .bundleJSON {
                    HStack(spacing: 8) {
                        TextField("ファイル名（拡張子不要）", text: $bundleFileName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 260)
                        Text(".json")
                            .foregroundStyle(.secondary)
                        Button {
                            // 再読み込みトリガ（描画サイクルで反映）
                            bundleLoadError = nil
                        } label: {
                            Label("再読み込み", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }

                    if let err = bundleLoadError {
                        Label(err, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    } else {
                        Text("Bundle内の \(bundleFileName).json を読み込みます。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 16) {
                    Label("物件: \(totalCount)", systemImage: "list.number")
                    Label("⭐︎: \(favoritesCount)", systemImage: "star.fill").foregroundStyle(.yellow)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
        .environmentObject(FavoritesStore())
}
