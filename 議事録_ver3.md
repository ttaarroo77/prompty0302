# プロジェクト管理議事録（更新版）

## 現在の課題
AIタグ提案機能が機能していない（優先度：高）、などの課題を抱えている。


### 1. パスワードリセット機能の500エラー（優先度：高）
- [x] Herokuでのパスワードリセットメール送信時に500エラーが発生
  - [x] エラーログの確認
  - [x] SMTP設定の確認（SendGridからGmailへの移行履歴あり）
  - [x] 本番環境での設定値の確認
  - [x] Gmail設定の修正完了

### 2. システムテストの失敗（優先度：中）
- [ ] プロンプト詳細画面のテスト失敗
  - [ ] `prompt_title`フィールドが見つからない
  - [ ] タイトル文字数制限のテスト失敗
- [ ] プロンプト一覧画面のテスト失敗
  - [ ] タイトル表示のテスト失敗
  - [ ] タグ表示のテスト失敗
  - [ ] 省略表示とツールチップのテスト失敗
- [ ] タグ入力のテスト失敗
  - [ ] `tag_name`フィールドが見つからない

### 3. タグ管理の不整合（優先度：中）
- [x] タグの重複登録の問題
  - [x] モデルレベルでの一意性制約追加済み
  - [x] データベースレベルでのユニークインデックス存在確認済み
  - [x] 重複登録時のリダイレクト処理追加済み

### 4. AIタグ提案機能が機能していない（優先度：高）
- [ ] AIタグ提案ボタンをクリックしても正常に動作しない
  - [ ] エラーが発生する可能性
  - [ ] タグ提案が表示されない問題

## 関連するファイル一覧（AIタグ提案機能関連）

1. **モデル関連**
   - `app/models/ai/tag_suggestion.rb` - AIタグ提案のモデル
   - `app/models/prompt.rb` - プロンプトモデル
   - `app/models/tag.rb` - タグモデル
   - `app/models/tagging.rb` - タグとプロンプトの関連付けモデル

2. **コントローラー関連**
   - `app/controllers/prompts_controller.rb` - AIタグ提案ボタンの処理
   - `app/controllers/tags_controller.rb` - タグ提案と追加処理

3. **ビュー関連**
   - `app/views/prompts/show.html.erb` - AIタグ提案ボタンと提案タグの表示
   - `app/views/tags/_suggested_tags.html.erb` - 提案タグの表示パーシャル
   - `app/views/tags/suggest.html.erb` - タグ提案ページ
   - `app/views/tags/suggest.turbo_stream.erb` - Turbo Streamによる非同期更新

4. **JavaScript関連**
   - `app/javascript/application.js` - 提案タグのクリックイベント処理

5. **サービス関連**
   - `app/services/tag_suggestion_service.rb` - タグ提案ロジック
   - `app/services/openai_client.rb` - OpenAI APIとの連携

6. **設定関連**
   - `config/initializers/load_tag_suggestion.rb` - AIモジュール読み込み設定
   - `db/migrate/20250404024154_create_ai_tag_suggestions.rb` - テーブル定義

## 想定される原因と対策の仮説

### 原因1: OpenAI APIキーの未設定または無効
- **仮説**: 環境変数`OPENAI_API_KEY`が未設定または無効な値になっている
- **対策**: 正しいAPIキーを環境変数に設定し、フォールバックメカニズムを実装

### 原因2: ユーザー認証の問題
- **仮説**: 未ログイン状態でのアクセス時に適切なエラーハンドリングができていない
- **対策**: 認証チェックとエラーハンドリングを強化

### 原因3: タグモデルのバリデーション問題
- **仮説**: タグの長さ制限が原因でタグの保存に失敗している
- **対策**: タグ名を自動的に切り詰める処理を追加

### 原因4: タグ提案サービスの実装ミス
- **仮説**: `get_existing_tags`メソッドが`prompt_id`カラム（存在しない）を参照している
- **対策**: タグの取得方法を修正してすべてのタグを正しく取得

### 原因5: JavaScript連携の問題
- **仮説**: 提案タグのクリックイベントが正しく動作していない
- **対策**: JavaScriptイベントリスナーの修正

### 原因6: モジュール読み込みの問題
- **仮説**: `AI::TagSuggestion`モジュールが正しく読み込まれていない
- **対策**: モジュール読み込みの設定を確認・修正

## 対策ロードマップ（チェックリスト方式）

### 高優先度
- [x] ログイン時のユーザー認証エラー対応
  - [x] `set_prompt`メソッドの修正でcurrent_userがnilの場合の処理追加
  - [x] before_actionの順序を調整して`authenticate_user!`を最初に実行
  - [x] showアクションで@promptがnilの場合の処理追加

- [ ] OpenAI API連携の修正
  - [ ] `.env`ファイルでのAPIキー設定確認
  - [ ] 本番環境での環境変数設定確認
  - [ ] APIキー未設定時のフォールバック実装

### 中優先度
- [ ] タグ提案サービスのデバッグと修正
  - [x] `get_existing_tags`メソッドの修正（prompt_id参照の排除）
  - [x] `find_matching_tags`メソッドの修正（タグ長さ制限対応）
  - [ ] ログ出力強化による問題箇所の特定
  - [ ] エラー時のフォールバックメカニズム強化

- [ ] ビューとJavaScriptの連携修正
  - [ ] 提案タグクリックイベントのデバッグ
  - [ ] デベロッパーツールでのコンソールエラー確認
  - [ ] イベントリスナーが正しく登録されているか確認

### 低優先度
- [ ] AIタグ提案機能のテスト実装
  - [ ] 単体テストの作成
  - [ ] 統合テストの作成
  - [ ] モックを使用したOpenAI API連携テスト

- [ ] ドキュメントとコード整理
  - [ ] コメントの追加と改善
  - [ ] コード重複部分のリファクタリング
  - [ ] 使用方法のドキュメント作成

## 対応計画

### 1. デバッグ実行計画
1. サーバーを起動して詳細なログを確認
   ```bash
   RAILS_ENV=development bundle exec rails server -p 3001
   ```

2. ログのデバッグレベルを上げて情報収集
   ```ruby
   # config/environments/development.rb
   config.log_level = :debug
   ```

3. ブラウザのデベロッパーツールでネットワークリクエストとJavaScriptエラーを監視

### 2. APIキー設定確認
1. 開発環境での`.env`ファイル確認
   ```bash
   grep OPENAI_API_KEY .env
   ```

2. Heroku環境変数の確認
   ```bash
   heroku config:get OPENAI_API_KEY -a prompty0302
   ```

3. 必要に応じて環境変数を設定
   ```bash
   heroku config:set OPENAI_API_KEY=xxxxxxxxxxxxxxxx -a prompty0302
   ```

### 3. タグ管理修正の再設定
1. タグの長さ制限を修正（21文字に統一）
2. ロギングを強化して問題の特定
3. フォールバックメカニズム（モックタグの生成）を実装

## 備考
- AIタグ提案機能はOpenAI APIに依存するため、APIキーがないと動作しない
- 問題解決の優先順位：認証エラー→タグ提案サービス→OpenAI API連携→UI/UX改善
- 本番環境では機密情報の取り扱いに注意
