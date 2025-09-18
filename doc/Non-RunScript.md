# Info.plist 運用ガイド（Run Script なし版）

## 方針（決めごと）

### 基本設定

- **既定は自動生成**
  - `GENERATE_INFOPLIST_FILE=YES`
  - `INFOPLIST_FILE` は空に設定
- **Copy Bundle Resources に Info.plist を入れない**

### カスタムキーの管理

- 追加キーは **Target > Info（Custom iOS Target Properties）** に **String** で追加
- 値は `$(KEY)` 形式で xcconfig 置換を使用
- 環境差分は **.xcconfig**（Debug/Release/Shared）で管理

## 反映確認方法（Run Script を使わない）

### 1. 実行時ログ（最短・安全）

ルート View（例：MainTabView）の `.task` で一度だけ出力：

```swift
struct MainTabView: View {
    @State private var didLog = false

    var body: some View {
        TabView { /* ... */ }
        .task {
            #if DEBUG
            guard !didLog else { return }
            didLog = true

            func v(_ k: String) -> String {
                Bundle.main.object(forInfoDictionaryKey: k) as? String ?? "nil"
            }

            print("[Config] BASE_URL=\(v("BASE_URL")) USE_API=\(v("USE_API")) FALLBACK=\(v("USE_FALLBACK"))")
            #endif
        }
    }
}
```

### 2. 簡易デバッグ画面（任意：UI で目視）

Debug ビルドのみ表示する設定パネルを用意し、Bundle.main から同様に表示。
→ 非エンジニアでも確認しやすくなります。

### 3. XCTest で自動チェック（CI 含む）

```swift
import XCTest

final class InfoPlistTests: XCTestCase {
    func testInfoPlistKeys() {
        let b = Bundle.main
        XCTAssertNotNil(b.object(forInfoDictionaryKey: "BASE_URL") as? String)
        XCTAssertNotNil(b.object(forInfoDictionaryKey: "USE_API") as? String)
        XCTAssertNotNil(b.object(forInfoDictionaryKey: "USE_FALLBACK") as? String)
    }
}
```

**メリット**: 実行プロセス内で読むのでサンドボックス問題が起きません。

### 4. CLI でビルド後に確認（手動/CI）

**重要**: Simulator 実行中に .app を直接読まないのがポイント。必要なら一旦コピーして確認。

```bash
# パス把握
xcodebuild -showBuildSettings -scheme RealEstateStarter -configuration Debug \
| grep -E 'TARGET_BUILD_DIR|INFOPLIST_PATH'

# 出力を使って一時コピー→検査
cp "<TARGET_BUILD_DIR>/<INFOPLIST_PATH>" /tmp/_Info.plist
plutil -p /tmp/_Info.plist | grep -E 'BASE_URL|USE_API|USE_FALLBACK'
```

## よくあるハマりと回避方法

### Multiple commands produce エラー

- **原因**: 自動生成と手動コピーの二重設定
- **対策**:
  - **Copy Bundle Resources から Info.plist を外す**
  - 自動生成か手動かをターゲット毎に統一する

### plutil の sandbox deny エラー

- **原因**: 最終 .app/Info.plist を外部ツールで読もうとした
- **対策**: **実行時ログ** または **XCTest** で確認する

### 置換が反映されない

- **原因**: xcconfig の設定不備
- **対策**:
  - **Base Configuration に .xcconfig を割当**
  - キー型は **String** に設定
  - 値は `$(KEY)` 形式で記述

## 安心のためのテンプレート

### 推奨実装

- **AppConfig** 経由で参照する薄いユーティリティ（既に導入済みなら OK）
- `docs/ios-info-plist.md` に本運用方法を保存
- PR テンプレに「Info.plist の運用変更は要記載」と一文追加

### 三段構え確認戦略

1. **日常確認**: 実行時ログ or デバッグ画面
2. **自動回帰**: XCTest
3. **必要時のみ**: CLI

## まとめ

この運用方法により以下の三重地雷を回避できます：

- **フェーズ順序** の問題
- **サンドボックス** の制限
- **権限** エラー

Run Script なしの確認方法を併用することで、再現性が高く安全な運用が実現できます。
