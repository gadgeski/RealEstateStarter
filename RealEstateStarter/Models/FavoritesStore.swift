//
//  FavoritesStore.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import Foundation
import Combine

final class FavoritesStore: ObservableObject {
    @Published private(set) var ids: Set<UUID> = []

    private let key = "favorite_property_ids_v1"

    init() { load() }

    func contains(_ id: UUID) -> Bool { ids.contains(id) }
    func isFavorite(_ property: Property) -> Bool { contains(property.id) }

    func toggle(_ id: UUID) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        save()
    }
    func toggle(_ property: Property) { toggle(property.id) }

    // MARK: - Persistence (UserDefaults, JSON [UUID])
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        if let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            ids = Set(decoded)
        }
    }
    private func save() {
        let arr = Array(ids)
        if let data = try? JSONEncoder().encode(arr) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
