//
//  PropertyListViewModel.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/16.
//

import Foundation

// View からは .load() / .reload() を呼ぶだけで OK。
// Repository は Local(API未接続) → Default(API) に差し替え可能。
@MainActor
final class PropertyListViewModel: ObservableObject {

    // 一覧データ（View 側は viewModel.properties を参照）
    @Published private(set) var properties: [Property] = []

    // ローディング／エラー状態（View の三分岐で使用）
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // [追加] 最終更新時刻（必要になったら View で表示可能）
    @Published private(set) var lastUpdated: Date?

    // データ取得口（Local → API へ差し替え可能）
    private var repository: PropertyRepository

    // [追加] 連打・多重起動対策用の Task ハンドル
    private var loadTask: Task<Void, Never>?

    // MARK: - Init / DI

    init(repository: PropertyRepository) {
        self.repository = repository
    }

    // [追加] 後から Repository を差し替える（例：Local → API）
    func updateRepository(_ newRepository: PropertyRepository) {
        // 進行中のロードがあれば中断
        loadTask?.cancel()                           // [追加]
        loadTask = nil                                // [追加]
        repository = newRepository                   // [追加]
    }

    // MARK: - Public API (View から呼ぶ)

    /// 初回や画面再表示時のロード。実行中は二重起動しない。
    func load() {
        guard !isLoading else { return }             // [追加] 二重起動防止
        startLoad(clearExisting: false)
    }

    /// 明示的な再取得（プル・トゥ・リフレッシュ等）
    func reload() {
        startLoad(clearExisting: false)              // [変更] 既存表示を維持して更新
    }

    /// 空から取り直したい場合（用途に応じて使用）
    func hardReload() {                               // [追加]
        startLoad(clearExisting: true)               // [追加]
    }

    /// エラー時の再試行（UIで使いやすいエイリアス）
    func retry() {                                    // [追加]
        startLoad(clearExisting: properties.isEmpty) // [追加]
    }

    // MARK: - Core loading

    private func startLoad(clearExisting: Bool) {
        // 既存タスクをキャンセル（最新のみ有効）
        loadTask?.cancel()                            // [追加]

        if clearExisting {
            properties = []                          // [追加] “空から”の再読込に対応
        }
        isLoading = true
        errorMessage = nil

        loadTask = Task { [weak self] in              // [追加] 最新タスクのみ有効化
            guard let self else { return }
            do {
                let items = try await self.repository.fetchProperties()
                // 更新（MainActor 配下）
                self.properties = items
                self.lastUpdated = Date()            // [追加] 最終更新時刻を更新
                self.errorMessage = nil
            } catch {
                // ユーザー向けに読めるメッセージへ
                if let le = error as? LocalizedError, let desc = le.errorDescription {
                    self.errorMessage = desc
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
            self.isLoading = false
        }
    }

    deinit {
        loadTask?.cancel()                            // [追加] リーク抑止
    }
}
