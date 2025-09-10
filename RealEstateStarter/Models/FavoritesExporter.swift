//
//  FavoritesExporter.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation

// ★ 追加: お気に入りのCSV/JSONエクスポート支援
enum FavoritesExporter {
    // CSVを文字列で返す
    static func csv(from items: [Property]) -> String {
        let header = [
            "id","title","rentJPY","layout","wardOrCity","area",
            "nearestStation","walkMinutes","latitude","longitude"
        ].joined(separator: ",")

        let rows = items.map { p -> String in
            func esc(_ s: String) -> String {
                "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
            }
            let lat = p.latitude.map { String($0) } ?? ""
            let lon = p.longitude.map { String($0) } ?? ""

            return [
                esc(p.id.uuidString),
                esc(p.title),
                String(p.rent),
                esc(p.layout),
                esc(p.wardOrCity),
                esc(p.area),
                esc(p.nearestStation),
                String(p.walkMinutes),
                esc(lat),
                esc(lon)
            ].joined(separator: ",")
        }

        return ([header] + rows).joined(separator: "\n")
    }

    // JSONをDataで返す（整形済み）
    static func json(from items: [Property]) throws -> Data {
        struct Payload: Codable {
            let id: UUID
            let title: String
            let rentJPY: Int
            let layout: String
            let wardOrCity: String
            let area: String
            let nearestStation: String
            let walkMinutes: Int
            let latitude: Double?
            let longitude: Double?

            init(_ p: Property) {
                id = p.id
                title = p.title
                rentJPY = p.rent
                layout = p.layout
                wardOrCity = p.wardOrCity
                area = p.area
                nearestStation = p.nearestStation
                walkMinutes = p.walkMinutes
                latitude = p.latitude
                longitude = p.longitude
            }
        }

        let payload = items.map(Payload.init)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try enc.encode(payload)
    }

    // 一時ファイルに書き出してURLを返す
    static func writeTempFile(named filename: String, contents: Data) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(filename)
        // 既存があれば消してから書く
        try? FileManager.default.removeItem(at: url)
        try contents.write(to: url, options: .atomic)
        return url
    }
}
