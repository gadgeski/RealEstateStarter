//
//  PropertyListViewModel.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/16.
//

import Foundation

// View からは .load() / .reload() / await .reload() を使う。
// Repository は Local(API未接続) → Default(API) に差し替え可能。
@MainActor
final class PropertyListViewModel: ObservableObject {

    // 一覧データ（View 側は viewModel.properties を参照）
    @Published private(set) var properties: [Property] = []

    // ローディング／エラー状態（View の三分岐で使用）
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // 最終更新時刻（Viewで「更新: HH:mm」等の表示に利用）
    @Published private(set) var lastUpdated: Date?

    // データ取得口（Local → API へ差し替え可能）
    private var repository: PropertyRepository

    // 連打・多重起動対策用の Task ハンドル
    private var loadTask: Task<Void, Never>?

    // MARK: - Init / DI

    init(repository: PropertyRepository) {
        self.repository = repository
    }

    // Repository を後から差し替える（例：Local → API）
    func updateRepository(_ newRepository: PropertyRepository) {
        loadTask?.cancel()
        loadTask = nil
        repository = newRepository
    }

    // MARK: - Public API (View から呼ぶ)

    /// 初回や画面再表示時のロード。実行中は二重起動しない。
    func load() {
        guard !isLoading else { return }
        startLoad(clearExisting: false)
    }

    /// 明示的な再取得（プル・トゥ・リフレッシュ等）。既存表示を維持して更新。
    func reload() {
        startLoad(clearExisting: false)
    }

    /// [追加] refreshable などから「待てる」版。UI側で `await` できる。
    func reload() async { // [追加]
        startLoad(clearExisting: false)             // [追加]
        let task = loadTask                         // [追加] 生成直後のタスクを握る
        await task?.value                           // [追加] 完了まで待機（UIは自動更新）
    }

    /// 一度空にしてから取り直したい場合
    func hardReload() {
        startLoad(clearExisting: true)
    }

    /// エラー時の再試行（UIで使いやすいエイリアス）
    func retry() {
        startLoad(clearExisting: properties.isEmpty)
    }

    // MARK: - Core loading

    private func startLoad(clearExisting: Bool) {
        // 既存タスクをキャンセル（最新のみ有効）
        loadTask?.cancel()

        if clearExisting {
            properties = []
        }
        isLoading = true
        errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let items = try await self.repository.fetchProperties()
                // 更新（MainActor 配下）
                self.properties = items
                self.lastUpdated = Date()
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
        loadTask?.cancel()
    }
}
