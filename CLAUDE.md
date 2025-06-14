# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクト概要

## ディレクトリ構成
- Extensions/      # Swift拡張機能
- Models/          # データモデル
- Protocols/       # プロトコル定義
- Resources/       # リソースファイル（アニメーションなど）
- Services/        # ビジネスロジック・サービス層
- Supports/        # ユーティリティ（定数、ログなど）
- ViewModifiers/   # Viewの修飾子
- Views/           # 画面・ビュー

## デザインガイドライン
- Appleの[ヒューマンインターフェースガイドライン](https://developer.apple.com/jp/design/human-interface-guidelines "HumanInterfaceGuildeline")に準拠する
- UIはAppleが用意した基本のコンポーネントを利用
- システムフォントを利用し、`.title`や`.body`のようなシステムに応じて可変となる指定を行う

## アーキテクチャ

### 基本構成
- SwiftUI + Observation: `@Observable`マクロによる状態管理
- レイヤー分離: Views → Services → Models
- Environmentを利用してDIを行う: `@Environment(VieDeviceStore.self) var store`

### 並行処理
- Swift Concurrency（async/await）
- Actor によるスレッドセーフなデータ管理
- `@MainActor`でUI更新を保証

## 実装指針
- SwiftUIのView以外はTDD(テスト駆動開発)で開発する
- 1つのメソッドは1つの関心がある処理を行う
- 副作用はなるべく抑える
- 1つのファイルは300行程度に収める

## テスト
- UnitTestはSwiftTestingを利用

## コーディング規約

### 命名規則

#### 型と型のようなもの
- **型名**（クラス、構造体、列挙型、プロトコル）: UpperCamelCase
  ```swift
  class SomeStore { }
  struct Message { }
  enum SomeType { }
  protocol Mappable { }
  ```

#### 変数、定数、プロパティ、メソッド
- **変数・定数・プロパティ**: lowerCamelCase
  ```swift
  var someStatus: SomeStatus
  let maxBufferCount = 1000
  @State private var isTextFieldFocused = false
  ```

- **メソッド名**: lowerCamelCase（動詞で始める）
  ```swift
  func startProcessing()
  func updateStatus(with value: Int)
  ```

- **Bool型**: is/has/shouldなどの接頭辞を使用
  ```swift
  var isShowMessage: String
  var hasNewData: Bool
  var shouldUpdate: Bool
  ```

### アクセス制御
- 最小限の公開範囲を使用（private > fileprivate > internal > public）
- SwiftUIのViewでは`private`を積極的に使用
  ```swift
  @State private var inputText = ""
  private func sendMessage() { }
  ```

### プロパティの順序
1. 型プロパティ（static）
2. インスタンスプロパティ
   - public
   - internal
   - private
3. 計算プロパティ

### メソッドの順序
1. イニシャライザ
2. ライフサイクルメソッド
3. publicメソッド
4. internalメソッド
5. privateメソッド

### マークコメント
セクションを分かりやすく区切る
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - View Builders
```

### SwiftUI固有の規約

#### View構造
```swift
struct SomeView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var someState = false
    @Binding var externalValue: String
    
    // MARK: - Methods
    private func handleAction() {
        // アクション処理
    }
    
    // MARK: - Body
    var body: some View {
        // メインのView構造
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private var headerView: some View {
        // 部分的なView
    }
}
```

#### @ViewBuilder
- 複雑なViewは`@ViewBuilder`で分割
- privateな計算プロパティとして定義

### 非同期処理
- async/awaitを積極的に使用
- Task内でのweak selfパターン
  ```swift
  Task { [weak self] in
      guard let self = self else { return }
      await self.performAsyncWork()
  }
  ```

### エラーハンドリング
- カスタムエラー型は`LocalizedError`に準拠
- エラーメッセージは明確に
  ```swift
  enum APIError: Error, LocalizedError {
      case invalidResponse
      
      var errorDescription: String? {
          switch self {
          case .invalidResponse:
              return "Invalid API response"
          }
      }
  }
  ```

### 定数
- グローバル定数は`Constants`構造体にまとめる
- マジックナンバーは避ける
  ```swift
  struct Constants {
      static let maxBufferSize = 360000
      static let samplingRate = 30
  }
  ```

### プロトコル準拠
- extensionで分離して実装
  ```swift
  struct MyType { }
  
  extension MyType: Codable {
      // Codable実装
  }
  ```

### インデント・スペース
- インデント: スペース4つ
- 演算子の前後にスペース
- カンマの後にスペース
- コロンの前にスペースなし、後にスペース
