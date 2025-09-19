// Tests/RealEstateStarterTests/PropertyListViewModelTests.swift
// [新規] ViewModel の 成功／失敗／フォールバック を検証するユニットテスト

import XCTest
@testable import RealEstateStarter   // ← アプリのターゲット名に合わせてください

final class PropertyListViewModelTests: XCTestCase {

    // MARK: - Helpers

    /// [新規] テスト用のサンプル Property を1件作成
    private func makeSample(
        id: UUID = UUID(),
        title: String = "サンプル物件",
        rent: Int = 120_000,
        layout: String = "1LDK",
        area: String = "東京都 渋谷区 恵比寿",
        wardOrCity: String = "渋谷区",
        nearest: String = "恵比寿",
        walk: Int = 7
    ) -> Property {
        Property(
            id: id,
            title: title,
            rent: rent,
            layout: layout,
            area: area,
            wardOrCity: wardOrCity,          // ← プロジェクト側で必須
            nearestStation: nearest,
            walkMinutes: walk,
            imageSystemName: "house.fill",
            latitude: nil,
            longitude: nil
        )
    }

    // MARK: - Tests

    func testReload_Success_PopulatesPropertiesAndLastUpdated() async {
        // [新規] 成功リポジトリを注入
        let repo = StubRepoSuccess(items: [makeSample()])
        let vm = PropertyListViewModel(repository: repo)

        await vm.reload() // async 版で完了待機

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.properties.count, 1)
        XCTAssertNotNil(vm.lastUpdated)
    }

    func testReload_Failure_SetsErrorAndKeepsEmpty() async {
        // [新規] 常に失敗するリポジトリを注入
        let repo = StubRepoFailure()
        let vm = PropertyListViewModel(repository: repo)

        await vm.reload()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)          // エラーメッセージが入る
        XCTAssertTrue(vm.properties.isEmpty)      // 既存が無ければ空のまま
        // lastUpdated は更新されない（nil のままが期待）
        XCTAssertNil(vm.lastUpdated)
    }

    func testReload_FallbackRepository_ReturnsItems_NoError() async {
        // [新規] “フォールバック結果を返す”リポジトリを注入
        // （VM からはフォールバックかどうかは区別できない＝成功扱い）
        let fallbackItems = [makeSample(title: "ローカルフォールバック", rent: 90_000)]
        let repo = StubRepoSuccess(items: fallbackItems)
        let vm = PropertyListViewModel(repository: repo)

        await vm.reload()

        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(vm.properties.map(\.title), ["ローカルフォールバック"])
        XCTAssertNotNil(vm.lastUpdated)
    }
}

// MARK: - Test Doubles

/// [新規] 成功するスタブ
private struct StubRepoSuccess: PropertyRepository {
    let items: [Property]
    func fetchProperties() async throws -> [Property] {
        // 擬似的な非同期待ち
        try? await Task.sleep(nanoseconds: 30_000_000)
        return items
    }
}

/// [新規] 常に失敗するスタブ
private struct StubRepoFailure: PropertyRepository {
    struct TestError: LocalizedError { var errorDescription: String? { "stub failure" } }
    func fetchProperties() async throws -> [Property] {
        try? await Task.sleep(nanoseconds: 30_000_000)
        throw TestError()
    }
}
