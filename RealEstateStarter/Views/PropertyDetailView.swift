//
//  PropertyDetailView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI
import MapKit

struct PropertyDetailView: View {
    let property: Property

    @State private var cameraPosition: MapCameraPosition
    @EnvironmentObject private var favorites: FavoritesStore   // ★ 追加: お気に入り共有Storeを参照

    init(property: Property) {
        self.property = property
        if let coord = property.coordinate {
            let region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            _cameraPosition = State(initialValue: .region(region))
        } else {
            // 座標が無い場合のフォールバック（東京駅周辺）
            let fallback = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            _cameraPosition = State(initialValue: .region(fallback))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ヒーロー領域（簡易サムネ）
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 72, height: 72)
                        Image(systemName: property.imageSystemName ?? "house.fill")
                            .font(.system(size: 30, weight: .semibold))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(property.title)
                            .font(.title2).bold()
                            .lineLimit(2)
                        Text(property.area)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                // 主要情報
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.rent, format: .currency(code: "JPY"))
                        .font(.title3).bold()

                    HStack(spacing: 10) {
                        Label(property.layout, systemImage: "bed.double")
                        Label("\(property.nearestStation) 徒歩\(property.walkMinutes)分", systemImage: "tram.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // 地図（座標がある場合のみピンを表示）
                if let coord = property.coordinate {
                    Map(position: $cameraPosition) {
                        Marker(property.title, coordinate: coord)
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // 詳細情報
                VStack(alignment: .leading, spacing: 8) {
                    Text("物件情報")
                        .font(.headline)
                    Divider()
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                        GridRow {
                            Text("所在地").foregroundStyle(.secondary)
                            Text(property.area)
                        }
                        GridRow {
                            Text("最寄駅").foregroundStyle(.secondary)
                            Text("\(property.nearestStation)（徒歩\(property.walkMinutes)分）")
                        }
                        GridRow {
                            Text("間取り").foregroundStyle(.secondary)
                            Text(property.layout)
                        }
                        GridRow {
                            Text("家賃").foregroundStyle(.secondary)
                            Text(property.rent, format: .currency(code: "JPY"))
                        }
                    }
                    .font(.subheadline)
                }

                Spacer(minLength: 12)
            }
            .padding()
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // ★ 追加: お気に入りトグル（右上の⭐︎）
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favorites.toggle(property) // ★ 追加: 追加/削除のトグル
                } label: {
                    Image(systemName: favorites.isFavorite(property) ? "star.fill" : "star") // ★ 追加: 状態に応じてアイコン切替
                        .imageScale(.large)
                }
                .accessibilityLabel(favorites.isFavorite(property) ? "お気に入りを解除" : "お気に入りに追加")
            }
        }
    }
}

#Preview {
    // ★ 追加: プレビューでも FavoritesStore を注入（未注入だとビルドエラー）
    PropertyDetailView(property: MockProperties.sample.first!)
        .environmentObject(FavoritesStore())
}
