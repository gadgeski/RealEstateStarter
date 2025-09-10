//
//  MapExploreView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI
import MapKit

struct MapExploreView: View {
    let properties: [Property]

    @State private var cameraPosition: MapCameraPosition

    init(properties: [Property]) {
        self.properties = properties

        // 座標がある物件の平均地点（なければ東京駅）
        let coords = properties.compactMap { $0.coordinate }
        if let avg = Self.averageCoordinate(of: coords) {
            let region = MKCoordinateRegion(
                center: avg,
                span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
            )
            _cameraPosition = State(initialValue: .region(region))
        } else {
            let fallback = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
            _cameraPosition = State(initialValue: .region(fallback))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Map(position: $cameraPosition) {
                ForEach(properties) { p in
                    if let coord = p.coordinate {
                        Marker(p.title, coordinate: coord)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // 簡易ヘッダー
            HStack {
                Text("地図に \(properties.filter { $0.coordinate != nil }.count) 件の物件")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.thinMaterial)
        }
        .navigationTitle("地図")
        .navigationBarTitleDisplayMode(.inline)
    }

    private static func averageCoordinate(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coords.isEmpty else { return nil }
        let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

#Preview {
    MapExploreView(properties: MockProperties.sample)
}
