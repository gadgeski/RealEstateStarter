//
//  Property.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation
import CoreLocation

struct Property: Identifiable, Hashable, Codable { // ★ 変更: Codableを追加
    let id: UUID
    let title: String
    let rent: Int
    let layout: String
    let area: String              // 例: "東京都渋谷区代々木"
    let wardOrCity: String        // 例: "渋谷区" / "武蔵野市" / "川崎市"
    let nearestStation: String
    let walkMinutes: Int
    let imageSystemName: String?

    // 位置情報（保存は数値、座標は計算プロパティ）
    let latitude: Double?
    let longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    init(
        id: UUID = UUID(),
        title: String,
        rent: Int,
        layout: String,
        area: String,
        wardOrCity: String,
        nearestStation: String,
        walkMinutes: Int,
        imageSystemName: String? = "house.fill",
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.rent = rent
        self.layout = layout
        self.area = area
        self.wardOrCity = wardOrCity
        self.nearestStation = nearestStation
        self.walkMinutes = walkMinutes
        self.imageSystemName = imageSystemName
        self.latitude = latitude
        self.longitude = longitude
    }

    // ★ 追加: JSONにidが無ければ新規UUIDを採番
    private enum CodingKeys: String, CodingKey {
        case id, title, rent, layout, area, wardOrCity, nearestStation, walkMinutes, imageSystemName, latitude, longitude
    }

    init(from decoder: Decoder) throws { // ★ 追加
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try c.decode(String.self, forKey: .title)
        self.rent = try c.decode(Int.self, forKey: .rent)
        self.layout = try c.decode(String.self, forKey: .layout)
        self.area = try c.decode(String.self, forKey: .area)
        self.wardOrCity = try c.decode(String.self, forKey: .wardOrCity)
        self.nearestStation = try c.decode(String.self, forKey: .nearestStation)
        self.walkMinutes = try c.decode(Int.self, forKey: .walkMinutes)
        self.imageSystemName = try c.decodeIfPresent(String.self, forKey: .imageSystemName)
        self.latitude = try c.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try c.decodeIfPresent(Double.self, forKey: .longitude)
    }
}
