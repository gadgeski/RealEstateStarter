# iOS Info.plist 運用ガイド（プロジェクト用）

## 0. 目的

- Info.plistの生成方法を一本化し、ビルドエラー（Multiple commands / sandbox deny）を防ぐ
- 環境差分は`.xcconfig`に集約して安全に置換する
- 反映確認の標準手順を決める

## 1. 方針を選ぶ（決定ツリー）

### A: 自動生成（推奨）
- `GENERATE_INFOPLIST_FILE = YES`（ターゲット）
- `INFOPLIST_FILE` は空
- 追加キーは `Target > Info`（Custom iOS Target Properties）からStringで追加（値は`$(BASE_URL)`等）

### B: 手動管理
- `GENERATE_INFOPLIST_FILE = NO`
- `INFOPLIST_FILE = $(SRCROOT)/…/Info.plist`
- `<dict>`内に`<key>BASE_URL</key><string>$(BASE_URL)</string>`などを記述

**注意**: 混在可だが、ターゲットごとに「自動 or 手動」を統一すること（両方はNG）

## 2. 設定手順

### A. 自動生成（推奨）

1. **TARGETS → Build Settings（All + Levels）**
   - `GENERATE_INFOPLIST_FILE = YES`
   - `INFOPLIST_FILE` は空

2. **PROJECT（青アイコン）側の Generate Info.plist File は空/NO**（波及防止）

3. **Build Phases → Copy Bundle Resources に Info.plist を入れない**

4. **Target > Info でカスタムキーを追加**（型 = String）
   - `BASE_URL = $(BASE_URL)`
   - `USE_API = $(USE_API)`
   - `USE_FALLBACK = $(USE_FALLBACK)` など

5. **Base Configuration に Debug.xcconfig / Release.xcconfig を割当**

### B. 手動管理

1. **Resources/Info.plist**（File Type = Property List）を用意

2. **TARGETS → Build Settings**
   - `GENERATE_INFOPLIST_FILE = NO`
   - `INFOPLIST_FILE = $(SRCROOT)/Resources/Info.plist`

3. **Copy Bundle Resources に Info.plist を入れない**

4. **`<dict>`内にキーを追記**（例）
   ```xml
   <key>BASE_URL</key><string>$(BASE_URL)</string>
   <key>USE_API</key><string>$(USE_API)</string>
   <key>USE_FALLBACK</key><string>$(USE_FALLBACK)</string>
   ```

5. **Base Configuration を割当**

## 3. .xcconfig の例

### Configurations/Shared.xcconfig
```
BASE_URL = https://your.api.example.com
USE_API = YES
USE_FALLBACK = YES
LOG_LEVEL = WARN
API_TIMEOUT_SECONDS = 15
```

### Configurations/Debug.xcconfig
```
#include "Shared.xcconfig"
BASE_URL = https://dev.api.example.com
LOG_LEVEL = DEBUG
```

### Configurations/Release.xcconfig
```
#include "Shared.xcconfig"
BASE_URL = https://api.example.com
```

**重要**: Base Configuration に Debug/Release を割当てるのを忘れない

## 4. 反映確認（安全な方法）

### 実行時ログ（推奨・簡単）
ルートViewの`.task`などで一度だけ出力：

```swift
#if DEBUG
print("[Config] BASE_URL =", Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "nil")
#endif
```

既に AppConfig があれば `print(AppConfig.baseURL)` でもOK。

### ビルド後にファイル確認（必要な場合のみ）
- **Run Script で .app 内を直接読まない**（サンドボックスでdenyされがち）
- 中間生成物 `PRODUCT_SETTINGS_PATH` を署名前に確認する（Run Script は Code Sign より前に配置）

## 5. よくあるエラー → 対処表

| 症状 | 原因 | 対処 |
|------|------|------|
| Multiple commands produce …/Info.plist | 自動生成＋手動コピーの二重 | **Copy Bundle Resources から Info.plist を削除**。自動 or 手動のどちらかに統一 |
| Sandbox: plutil deny file-read-data | .app 内の最終 Info.plist を外部ツールで読んだ | **最終 .plist を読まない**。実行時ログ or 中間 PRODUCT_SETTINGS_PATH を使用 |
| Cannot code sign because the target does not have an Info.plist… | GENERATE_INFOPLIST_FILE=NO なのに INFOPLIST_FILE 未設定 | 自動にする（YES, INFOPLIST_FILE空）or 手動にする（NO, INFOPLIST_FILE設定）のどちらかに |
| 置換が反映されない | Base Configuration 未設定 / キー型がBool等 | .xcconfig を割当、キー型は String、値は $(KEY) |

## 6. コマンドで最終設定を確認

```bash
# ターゲットに効いている最終値を確認
xcodebuild -showBuildSettings -scheme RealEstateStarter -configuration Debug \
| grep -E 'GENERATE_INFOPLIST_FILE|INFOPLIST_FILE|TARGET_BUILD_DIR|INFOPLIST_PATH'
```

## 7. チーム運用ルール（例）

- 既定は**自動生成**。手動にしたいターゲットは PR で明記
- **Copy Bundle Resources に Info.plist を入れない**
- **最終 .app/Info.plist を plutil しない**（必要なら中間 PRODUCT_SETTINGS_PATH）
- 環境差分は `.xcconfig` に集約、コードは AppConfig 経由で参照

## 付録：AppConfig の例

```swift
enum AppConfig {
    static let baseURL: URL = {
        if let s = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
           let u = URL(string: s) { return u }
        return URL(string: "https://your.api.example.com")!
    }()
    static let useAPI: Bool = bool("USE_API", default: true)
    static let useFallback: Bool = bool("USE_FALLBACK", default: true)

    private static func bool(_ key: String, default def: Bool) -> Bool {
        let raw = (Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "").lowercased()
        switch raw { 
        case "1","true","yes": return true
        case "0","false","no": return false 
        default: return def 
        }
    }
}
```

## まとめ

- **決定（自動or手動）→手順→検証→トラブル対処**の順で"プロジェクト標準"を一枚に
- **「Copy Bundle Resourcesに入れない」「最終 .plist を外部から読まない」**の2点を重要ポイントとして強調
- このテンプレを `docs/ios-info-plist.md` に置くと、次回以降のハマりが激減します
