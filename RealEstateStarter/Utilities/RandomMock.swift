//
//  RandomMock.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation
import CoreLocation

// ★ 追加: ランダムにモック物件を生成（動作確認用）
enum RandomMock {
    static func properties(count: Int) -> [Property] {
        let wards = ["渋谷区","新宿区","目黒区","世田谷区","品川区","豊島区","中野区","杉並区","江東区","台東区","千代田区","武蔵野市","川崎市"]
        let stations = ["渋谷","新宿","中目黒","三軒茶屋","池袋","高円寺","門前仲町","豊洲","秋葉原","神田","吉祥寺","川崎","代々木","目白","西新宿"]
        let symbols = ["house.fill","building.2.fill","building.columns.fill","door.left.hand.open","building.fill","leaf.fill"]

        func randomArea(for ward: String) -> String {
            switch ward {
            case "川崎市": return "神奈川県川崎市"
            case "武蔵野市": return "東京都武蔵野市"
            default: return "東京都\(ward)"
            }
        }

        func randomCoordinate() -> CLLocationCoordinate2D? {
            // たまに座標なしにしてフォールバック確認
            if Bool.random() { return nil }
            // 東京中心付近をベースに少し散らす
            let baseLat = 35.68, baseLon = 139.76
            let lat = baseLat + Double.random(in: -0.08...0.08)
            let lon = baseLon + Double.random(in: -0.10...0.10)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        var list: [Property] = []
        list.reserveCapacity(count)

        for _ in 0..<count {
            let ward = wards.randomElement()!
            let station = stations.randomElement()!
            let layoutOptions = ["1K","1DK","1LDK","2DK","2LDK"]
            let layout = layoutOptions.randomElement()!
            let size = String(format: "%.1f㎡", Double.random(in: 24.0...62.0))
            let rent = Int.random(in: 90_000...260_000) / 1000 * 1000 // 千円丸め
            let walk = Int.random(in: 1...15)
            let title = "\(station)サイド \(Int.random(in: 101...1509))"
            let symbol = symbols.randomElement()!
            let area = randomArea(for: ward)
            let coord = randomCoordinate()

            list.append(
                Property(
                    title: title,
                    rent: rent,
                    layout: "\(layout) / \(size)",
                    area: area,
                    wardOrCity: ward,
                    nearestStation: "\(station)駅",
                    walkMinutes: walk,
                    imageSystemName: symbol,
                    latitude: coord?.latitude,
                    longitude: coord?.longitude
                )
            )
        }
        return list
    }
}
