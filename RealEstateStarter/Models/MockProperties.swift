//
//  MockProperties.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation

enum MockProperties {
    static let sample: [Property] = [
        Property(
            title: "グリーンヒルズ代々木 203",
            rent: 145000,
            layout: "1LDK / 35.2㎡",
            area: "東京都渋谷区代々木",
            wardOrCity: "渋谷区",
            nearestStation: "代々木駅",
            walkMinutes: 6,
            imageSystemName: "building.2.fill",
            latitude: 35.6841,
            longitude: 139.7020
        ),
        Property(
            title: "サンライズ中目黒 402",
            rent: 168000,
            layout: "1LDK / 40.1㎡",
            area: "東京都目黒区上目黒",
            wardOrCity: "目黒区",
            nearestStation: "中目黒駅",
            walkMinutes: 8,
            imageSystemName: "house.fill",
            latitude: 35.6440,
            longitude: 139.6980
        ),
        Property(
            title: "パークサイド神楽坂 101",
            rent: 122000,
            layout: "1DK / 28.5㎡",
            area: "東京都新宿区矢来町",
            wardOrCity: "新宿区",
            nearestStation: "神楽坂駅",
            walkMinutes: 3,
            imageSystemName: "door.left.hand.open",
            latitude: 35.7043,
            longitude: 139.7356
        ),
        Property(
            title: "ブリーズ西新宿 708",
            rent: 199000,
            layout: "2LDK / 52.8㎡",
            area: "東京都新宿区西新宿",
            wardOrCity: "新宿区",
            nearestStation: "西新宿駅",
            walkMinutes: 5,
            imageSystemName: "building.columns.fill",
            latitude: 35.6940,
            longitude: 139.6920
        ),
        Property(
            title: "恵比寿ガーデンハイツ 1203",
            rent: 210000,
            layout: "2LDK / 55.0㎡",
            area: "東京都渋谷区恵比寿",
            wardOrCity: "渋谷区",
            nearestStation: "恵比寿駅",
            walkMinutes: 7,
            imageSystemName: "house.fill",
            latitude: 35.6467,
            longitude: 139.7101
        ),
        Property(
            title: "吉祥寺テラス 305",
            rent: 138000,
            layout: "1LDK / 32.4㎡",
            area: "東京都武蔵野市吉祥寺本町",
            wardOrCity: "武蔵野市",
            nearestStation: "吉祥寺駅",
            walkMinutes: 5,
            imageSystemName: "building.fill",
            latitude: 35.7033,
            longitude: 139.5804
        ),
        Property(
            title: "池袋シティコート 901",
            rent: 155000,
            layout: "1LDK / 38.0㎡",
            area: "東京都豊島区西池袋",
            wardOrCity: "豊島区",
            nearestStation: "池袋駅",
            walkMinutes: 6,
            imageSystemName: "building.2.crop.circle",
            latitude: 35.7289,
            longitude: 139.7111
        ),
        Property(
            title: "中野フォレスト 204",
            rent: 125000,
            layout: "1DK / 30.2㎡",
            area: "東京都中野区中野",
            wardOrCity: "中野区",
            nearestStation: "中野駅",
            walkMinutes: 5,
            imageSystemName: "leaf.fill",
            latitude: 35.7074,
            longitude: 139.6639
        ),
        Property(
            title: "高円寺パークホームズ 307",
            rent: 129000,
            layout: "1DK / 29.8㎡",
            area: "東京都杉並区高円寺南",
            wardOrCity: "杉並区",
            nearestStation: "高円寺駅",
            walkMinutes: 7,
            imageSystemName: "building.2.fill",
            latitude: 35.7050,
            longitude: 139.6490
        ),
        Property(
            title: "大井町レジデンス 1102",
            rent: 175000,
            layout: "1LDK / 41.5㎡",
            area: "東京都品川区大井",
            wardOrCity: "品川区",
            nearestStation: "大井町駅",
            walkMinutes: 4,
            imageSystemName: "house.fill",
            latitude: 35.6073,
            longitude: 139.7345
        ),
        Property(
            title: "品川シーサイドビュー 2005",
            rent: 189000,
            layout: "2LDK / 50.3㎡",
            area: "東京都品川区東品川",
            wardOrCity: "品川区",
            nearestStation: "品川シーサイド駅",
            walkMinutes: 5,
            imageSystemName: "building.2.fill",
            latitude: 35.6079,
            longitude: 139.7480
        ),
        Property(
            title: "神田リバーフロント 602",
            rent: 142000,
            layout: "1LDK / 33.0㎡",
            area: "東京都千代田区神田",
            wardOrCity: "千代田区",
            nearestStation: "神田駅",
            walkMinutes: 6,
            imageSystemName: "building.columns.fill",
            latitude: 35.6917,
            longitude: 139.7708
        ),
        Property(
            title: "秋葉原ステーションコート 1003",
            rent: 165000,
            layout: "1LDK / 36.2㎡",
            area: "東京都千代田区外神田",
            wardOrCity: "千代田区",
            nearestStation: "秋葉原駅",
            walkMinutes: 4,
            imageSystemName: "building.fill",
            latitude: 35.6983,
            longitude: 139.7731
        ),
        Property(
            title: "浅草スカイハウス 503",
            rent: 128000,
            layout: "1DK / 28.9㎡",
            area: "東京都台東区浅草",
            wardOrCity: "台東区",
            nearestStation: "浅草駅",
            walkMinutes: 6,
            imageSystemName: "building.2.fill",
            latitude: 35.7119,
            longitude: 139.7967
        ),
        Property(
            title: "豊洲ベイフロント 2610",
            rent: 238000,
            layout: "2LDK / 60.0㎡",
            area: "東京都江東区豊洲",
            wardOrCity: "江東区",
            nearestStation: "豊洲駅",
            walkMinutes: 5,
            imageSystemName: "building.2.fill",
            latitude: 35.6549,
            longitude: 139.7976
        ),
        Property(
            title: "門前仲町リバーサイド 702",
            rent: 139000,
            layout: "1LDK / 32.0㎡",
            area: "東京都江東区門前仲町",
            wardOrCity: "江東区",
            nearestStation: "門前仲町駅",
            walkMinutes: 5,
            imageSystemName: "house.fill",
            latitude: 35.6719,
            longitude: 139.7986
        ),
        Property(
            title: "目白ガーデンプレイス 402",
            rent: 152000,
            layout: "1LDK / 34.5㎡",
            area: "東京都豊島区目白",
            wardOrCity: "豊島区",
            nearestStation: "目白駅",
            walkMinutes: 6,
            imageSystemName: "building.2.fill",
            latitude: 35.7216,
            longitude: 139.7062
        ),
        Property(
            title: "三軒茶屋ヒルズ 1201",
            rent: 168000,
            layout: "1LDK / 38.8㎡",
            area: "東京都世田谷区太子堂",
            wardOrCity: "世田谷区",
            nearestStation: "三軒茶屋駅",
            walkMinutes: 5,
            imageSystemName: "house.fill",
            latitude: 35.6433,
            longitude: 139.6694
        ),
        Property(
            title: "亀戸サウススクエア 803",
            rent: 119000,
            layout: "1DK / 27.4㎡",
            area: "東京都江東区亀戸",
            wardOrCity: "江東区",
            nearestStation: "亀戸駅",
            walkMinutes: 6,
            imageSystemName: "building.2.fill",
            latitude: 35.6965,
            longitude: 139.8268
        ),
        Property(
            title: "川崎リバータワー 1904",
            rent: 175000,
            layout: "2LDK / 48.0㎡",
            area: "神奈川県川崎市幸区",
            wardOrCity: "川崎市",
            nearestStation: "川崎駅",
            walkMinutes: 8,
            imageSystemName: "building.2.fill",
            latitude: 35.5317,
            longitude: 139.6969
        )
    ]
}
