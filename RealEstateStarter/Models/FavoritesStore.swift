//
//  FavoritesStore.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

// Models/FavoritesStore.swift
import Foundation
import Combine   // ← [追加] ObservableObject / @Published 用

/// お気に入りの永続化付き Store（UserDefaults）
/// - 既存の呼び出し: `isFavorite(_:)` / `toggle(_:)` はそのまま利用可能
/// - 起動時に自動で復元、変更時に即保存
@MainActor
final class FavoritesStore: ObservableObject {

    // MARK: - Types

    /// UserDefaults で使うキー
    private enum StorageKey {
        static let v1 = "FavoritesStore.ids.v1"        // [追加] 現行
        static let legacyArray = "favorites.ids"       // [追加] 旧キー（あれば移行）
    }

    // MARK: - State

    /// お気に入りの Property.id 集合
    @Published private(set) var ids: Set<UUID> = []    // [変更] 内部名を明確化（外部APIは従来通り）

    // MARK: - Init

    init() {
        load()                                         // [追加] 起動時に自動復元
    }

    // MARK: - Query

    /// 物件がお気に入りかどうか
    func isFavorite(_ property: Property) -> Bool {
        ids.contains(property.id)
    }

    /// 物件IDでの判定（必要に応じて）
    func isFavorite(id: UUID) -> Bool {
        ids.contains(id)
    }

    // MARK: - Mutation

    /// トグル（追加/削除）
    func toggle(_ property: Property) {
        if ids.contains(property.id) {
            ids.remove(property.id)
        } else {
            ids.insert(property.id)
        }
        save()                                         // [追加] 変更のたびに保存
    }

    /// 明示的に追加
    func add(_ property: Property) {
        guard !ids.contains(property.id) else { return }
        ids.insert(property.id)
        save()                                         // [追加]
    }

    /// 明示的に削除
    func remove(_ property: Property) {
        guard ids.contains(property.id) else { return }
        ids.remove(property.id)
        save()                                         // [追加]
    }

    /// すべて削除（デバッグ/テスト用）
    func removeAll() {
        ids.removeAll()
        save()                                         // [追加]
    }

    // MARK: - Persistence (UserDefaults)

    private func load() {
        let ud = UserDefaults.standard

        // [追加] v1（Data<JSON [UUID]>）を優先して読む
        if let data = ud.data(forKey: StorageKey.v1) {
            do {
                let decoded = try JSONDecoder().decode([UUID].self, from: data)
                self.ids = Set(decoded)
                return
            } catch {
                // 壊れていたら落とさずログのみに
                #if DEBUG
                print("[FavoritesStore] Failed to decode v1:", error)
                #endif
            }
        }

        // [追加] 旧形式（[String]）があればマイグレーション
        if let legacy = ud.array(forKey: StorageKey.legacyArray) as? [String] {
            let migrated = legacy.compactMap(UUID.init(uuidString:))
            self.ids = Set(migrated)
            // v1 に保存して旧キーは消す
            save()
            ud.removeObject(forKey: StorageKey.legacyArray)
            return
        }

        // どちらも無ければ空で開始
        self.ids = []
    }

    private func save() {
        let ud = UserDefaults.standard
        do {
            // [追加] JSON の Data として保存（型進化に強い）
            let data = try JSONEncoder().encode(Array(ids))
            ud.set(data, forKey: StorageKey.v1)
        } catch {
            #if DEBUG
            print("[FavoritesStore] Failed to encode:", error)
            #endif
        }
    }
}
