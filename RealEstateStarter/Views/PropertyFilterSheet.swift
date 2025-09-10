//
//  PropertyFilterSheet.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct PropertyFilterSheet: View {
    @Binding var filter: PropertyFilter
    let rentRange: ClosedRange<Int>
    let areas: [String]

    private let walkRange: ClosedRange<Int> = 1...30
    @Environment(\.dismiss) private var dismiss

    // ★ 型とモジュールを明示
    private var bindingMaxRent: SwiftUI.Binding<Int> {
        SwiftUI.Binding<Int>(
            get: { filter.maxRent ?? rentRange.upperBound },
            set: { filter.maxRent = $0 }
        )
    }

    // ★ 型とモジュールを明示
    private var bindingMaxWalk: SwiftUI.Binding<Int> {
        SwiftUI.Binding<Int>(
            get: { filter.maxWalkMinutes ?? walkRange.upperBound },
            set: { filter.maxWalkMinutes = $0 }
        )
    }

    var body: some View {
        Form {
            // 家賃
            Section("家賃の上限") {
                // ★ isOn の Binding を明示
                Toggle("制限なし", isOn: SwiftUI.Binding<Bool>(
                    get: { filter.maxRent == nil },
                    set: { noLimit in
                        filter.maxRent = noLimit ? nil : (filter.maxRent ?? rentRange.upperBound)
                    }
                ))
                if filter.maxRent != nil {
                    Stepper(value: bindingMaxRent, in: rentRange, step: 5000) {
                        Text("〜 \(bindingMaxRent.wrappedValue.formatted(.currency(code: "JPY"))) ")
                    }
                }
                Text("範囲：\(rentRange.lowerBound.formatted(.currency(code: "JPY")))〜\(rentRange.upperBound.formatted(.currency(code: "JPY")))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            // 徒歩
            Section("駅からの徒歩分数の上限") {
                // ★ isOn の Binding を明示
                Toggle("制限なし", isOn: SwiftUI.Binding<Bool>(
                    get: { filter.maxWalkMinutes == nil },
                    set: { noLimit in
                        filter.maxWalkMinutes = noLimit ? nil : (filter.maxWalkMinutes ?? walkRange.upperBound)
                    }
                ))
                if filter.maxWalkMinutes != nil {
                    Stepper(value: bindingMaxWalk, in: walkRange, step: 1) {
                        Text("〜 \(bindingMaxWalk.wrappedValue) 分")
                    }
                }
            }

            // 並び替え
            Section("並び替え") {
                Picker("並び替え", selection: $filter.sort) {
                    ForEach(PropertyFilter.Sort.allCases) { s in
                        Text(s.label).tag(s)
                    }
                }
                .pickerStyle(.menu)
            }

            // エリア（区市）
            Section("エリア（区市）") {
                if areas.isEmpty {
                    Text("候補がありません").foregroundStyle(.secondary)
                } else {
                    ForEach(areas, id: \.self) { area in
                        // ★ isOn の Binding を明示
                        Toggle(area, isOn: SwiftUI.Binding<Bool>(
                            get: { filter.selectedAreas.contains(area) },
                            set: { on in
                                if on { filter.selectedAreas.insert(area) }
                                else { filter.selectedAreas.remove(area) }
                            }
                        ))
                    }

                    HStack {
                        Button("全選択") { filter.selectedAreas = Set(areas) }
                        Button("全解除", role: .destructive) { filter.selectedAreas.removeAll() }
                    }

                    Text("未選択＝制限なし").font(.footnote).foregroundStyle(.secondary)
                }
            }

            Section {
                Button("リセット", role: .destructive) { filter.reset() }
            }
        }
        .navigationTitle("絞り込み")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("閉じる") { dismiss() }
            }
        }
    }
}

private struct PropertyFilterSheet_PreviewHost: View {
    @State private var f = PropertyFilter()

    var body: some View {
        NavigationStack {
            PropertyFilterSheet(
                filter: $f,
                rentRange: 100000...250000,
                areas: ["渋谷区", "新宿区", "目黒区", "武蔵野市"]
            )
        }
    }
}

#Preview("FilterSheet") {
    PropertyFilterSheet_PreviewHost()
}
