# RealEstateStarter

SwiftUI で構築された不動産物件検索・管理アプリケーションです。物件の検索、フィルタリング、お気に入り管理、地図表示などの機能を提供します。

## 🚀 主な機能

### 🏠 物件管理

- **物件一覧表示**: リスト形式での物件表示
- **詳細情報**: 物件の住所、家賃、間取り、最寄り駅などの詳細情報
- **検索機能**: 物件名、エリア、駅名での検索
- **高度なフィルタリング**: 家賃上限、徒歩分数、エリア選択による絞り込み
- **並び替え**: 家賃や徒歩分数での昇順・降順ソート

### ⭐ お気に入り機能

- **お気に入り登録・解除**: 星アイコンまたはスワイプで簡単操作
- **お気に入り一覧**: 専用画面でお気に入り物件を管理
- **データ永続化**: UserDefaults を使用してお気に入り情報を保存
- **エクスポート機能**: CSV/JSON 形式でお気に入りデータを書き出し・共有

### 🗺️ 地図機能

- **地図表示**: MapKit を使用した物件位置の可視化
- **ピン表示**: 各物件の位置にマーカーを表示
- **自動中心位置調整**: 物件の平均位置を中心に地図を表示

### 🔧 開発者向け機能

- **デバッグパネル**: 複数のデータセット切り替え
- **Bundle JSON 読み込み**: アプリ内の JSON ファイルから物件データを読み込み
- **ランダムデータ生成**: テスト用のモック物件データ生成
- **プル・トゥ・リフレッシュ**: データ更新機能（将来の API 連携に対応）

## 📱 画面構成

### タブ構成

1. **物件タブ**: 物件一覧・検索・フィルタリング
2. **地図タブ**: 地図上での物件表示
3. **設定タブ**: アプリケーション設定

### 主要画面

- `PropertyListView`: 物件一覧とフィルタリング
- `PropertyDetailView`: 物件詳細情報と地図
- `FavoritesListView`: お気に入り物件管理
- `MapExploreView`: 地図での物件探索
- `PropertyFilterSheet`: 高度な検索・フィルタリング

## 🏗️ アーキテクチャ

### データモデル

- `Property`: 物件情報を表現するメインモデル（Codable 対応）
- `PropertyFilter`: 検索・フィルタ条件を管理
- `FavoritesStore`: お気に入り状態の管理（ObservableObject）

### ユーティリティ

- `FavoritesExporter`: CSV/JSON エクスポート機能
- `PropertyBundleLoader`: Bundle 内 JSON ファイルの読み込み
- `RandomMock`: テスト用データ生成
- `MockProperties`: サンプルデータ提供

## 🛠️ 技術スタック

- **フレームワーク**: SwiftUI (iOS 18.5+, macOS 15.5+)
- **地図**: MapKit
- **位置情報**: CoreLocation
- **データ永続化**: UserDefaults + JSON
- **UI**: ネイティブ SwiftUI コンポーネント

## 📂 プロジェクト構造

```
RealEstateStarter/
├── Models/
│   ├── Property.swift           # メインデータモデル
│   ├── PropertyFilter.swift     # フィルタ条件管理
│   ├── FavoritesStore.swift     # お気に入り状態管理
│   ├── FavoritesExporter.swift  # エクスポート機能
│   └── MockProperties.swift     # サンプルデータ
├── Views/
│   ├── ContentView.swift        # デバッグ用メイン画面
│   ├── MainTabView.swift        # タブビュー
│   ├── PropertyListView.swift   # 物件一覧
│   ├── PropertyDetailView.swift # 物件詳細
│   ├── FavoritesListView.swift  # お気に入り一覧
│   ├── MapExploreView.swift     # 地図表示
│   └── PropertyFilterSheet.swift # フィルタ画面
├── Utilities/
│   ├── PropertyBundleLoader.swift # JSON 読み込み
│   └── RandomMock.swift         # ランダムデータ生成
└── Resources/
    └── properties.json          # サンプル物件データ
```

## 🚀 開始方法

1. Xcode 16.4+ で `RealEstateStarter.xcodeproj` を開く
2. iOS Simulator または実機でビルド・実行
3. デバッグパネルで任意のデータセットを選択して動作確認

## 💪 このアプリケーションの強み

### 1. **包括的な不動産アプリ機能**

- 物件検索からお気に入り管理、地図表示まで、不動産アプリに必要な機能を一通り網羅
- 実用的なフィルタリング（家賃・徒歩時間・エリア）で実際の物件探しに近い体験を提供

### 2. **優れた開発者体験**

- デバッグパネルによる複数データセットの切り替えで、開発・テスト効率が高い
- Bundle JSON 読み込み機能で、外部データとの連携テストが容易
- ランダムデータ生成で大量データでの動作確認が可能

### 3. **モダンな SwiftUI 設計**

- `@StateObject`、`@EnvironmentObject` を適切に使用した状態管理
- `NavigationStack` や `NavigationDestination` による最新のナビゲーション実装
- プル・トゥ・リフレッシュなどのネイティブ UX パターンを採用

### 4. **実用的なデータ管理**

- Codable 対応により JSON との相互変換が簡単
- UserDefaults による軽量な永続化
- CSV/JSON エクスポートで外部ツールとの連携が可能

### 5. **将来拡張性への配慮**

- API 連携への移行を想定したアーキテクチャ
- マルチプラットフォーム対応（iOS/macOS/visionOS）
- モジュール化された構造で機能追加が容易

## 🤔 SwiftUI を選んだ理由（推測）

### 1. **クロスプラットフォーム対応**

プロジェクト設定を見ると、iOS、macOS、visionOS をサポートしており、SwiftUI の「一度書けば複数プラットフォームで動く」という特徴を活用している

### 2. **不動産アプリに適した UI 要素**

- `NavigationStack` による階層ナビゲーション（一覧 → 詳細）
- `TabView` による機能分割（物件・地図・設定）
- `List` と `Map` の組み合わせによる直感的な物件表示
- `SearchBar` や `Sheet` による自然な検索・フィルタ体験

### 3. **MapKit との親和性**

SwiftUI の `Map` ビューは宣言的に記述でき、物件の位置情報表示に最適

### 4. **状態管理の簡潔性**

`@State`、`@StateObject`、`@EnvironmentObject` により、お気に入り状態やフィルタ条件の管理が直感的

### 5. **開発効率とプロトタイピング**

- SwiftUI Preview による高速な UI 確認
- 宣言的な記述による可読性の高いコード
- Hot Reload による開発サイクルの短縮

### 6. **モダンな iOS 開発のベストプラクティス**

最新の iOS 開発トレンドに沿った技術選択により、長期的な保守性と拡張性を確保

SwiftUI は特に不動産アプリのような「一覧表示・詳細表示・地図表示」が中心となるアプリケーションにおいて、その宣言的な UI 構築とネイティブコンポーネントの豊富さが大きな利点となっていると考えられます。
