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
        HStack(alignment: .top, spacing: 12) {
            // 今回はSF Symbolsをサムネイル代わりに使用（画像アセット不要）
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 64, height: 64)
                Image(systemName: property.imageSystemName ?? "house")
                    .font(.system(size: 28, weight: .semibold))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(property.title)
                    .font(.headline)
                    .lineLimit(2)

                // 家賃表記（円）
                Text(property.rent, format: .currency(code: "JPY"))
                    .font(.title3).bold()

                HStack(spacing: 8) {
                    Label(property.layout, systemImage: "bed.double")
                    Label("\(property.nearestStation) 徒歩\(property.walkMinutes)分", systemImage: "tram.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(property.area)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        ForEach(MockProperties.sample) { p in
            PropertyRow(property: p)
        }
    }
}
