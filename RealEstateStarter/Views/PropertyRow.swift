//
//  PropertyRow.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct PropertyRow: View {
    let property: Property

    var body: some View {
        HStack(spacing: 12) {
            // [追加] アイコン（仮）— 画像未整備でも形になる
            Image(systemName: property.imageSystemName ?? "house.fill")
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(.quaternary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                // タイトル
                Text(property.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .accessibilityLabel("\(property.title)")

                // [変更] 価格を太字＋モノスペースで視認性UP
                Text(property.rent.formatted(.currency(code: "JPY")))
                    .font(.title3)               // ← ここで大きめ
                    .fontWeight(.bold)
                    .monospacedDigit()           // ← 桁ブレ防止
                    .accessibilityLabel("家賃 \(property.rent)円")

                // レイアウト・徒歩・エリア
                HStack(spacing: 8) {
                    Label(property.layout, systemImage: "square.grid.2x2")
                    Label("徒歩\(property.walkMinutes)分", systemImage: "figure.walk")
                    Label(property.wardOrCity, systemImage: "mappin.and.ellipse")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 6)
    }
}

#Preview {
    PropertyRow(property: MockProperties.sample.first!)
        .padding()
}
