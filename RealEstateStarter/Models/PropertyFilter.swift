//
//  PropertyFilter.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation

struct PropertyFilter: Equatable {
    var query: String = ""
    var maxRent: Int? = nil
    var maxWalkMinutes: Int? = nil
    var sort: Sort = .rentAsc

    // ★ 追加: エリア（区市）の複数選択（未選択=制限なし）
    var selectedAreas: Set<String> = []

    enum Sort: String, CaseIterable, Identifiable {
        case rentAsc, rentDesc, walkAsc, walkDesc
        var id: Self { self }
        var label: String {
            switch self {
            case .rentAsc:  return "家賃 ↑"
            case .rentDesc: return "家賃 ↓"
            case .walkAsc:  return "徒歩 ↑"
            case .walkDesc: return "徒歩 ↓"
            }
        }
    }

    mutating func reset() {
        self = PropertyFilter()
    }
}
