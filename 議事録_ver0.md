# プロジェクト管理議事録

## 現在の課題

### システムテストの失敗
- [ ] `edit_prompt_path`が未定義
  - [ ] ルーティングの確認と修正
  - [ ] テストケースの修正
- [ ] プロンプト一覧画面のテスト失敗
  - [ ] タイトル表示の問題
  - [ ] タグ表示の問題
  - [ ] 省略表示とツールチップの実装
- [ ] タグ入力フィールドが見つからない
  - [ ] フィールドの実装確認
  - [ ] テストケースの修正

### タグ管理の不整合
- [ ] 中間テーブルの統一
  - [x] `taggings`と`prompt_tags`の使用状況調査
  - [x] 一本化する中間テーブルの決定
  - [x] 不要なテーブルの削除計画
- [ ] データアクセスの修正
  - [ ] コントローラーのタグ取得ロジック修正
  - [ ] 既存データの移行計画
- [ ] モデル定義の整理
  - [x] リレーションの見直し
  - [x] バリデーションの確認

## 今後のタスク計画

### 1. システムテストの修正（優先度：高）
- [ ] プロンプト詳細画面のテスト修正
  - [ ] `prompt_title`フィールドの修正
  - [ ] タイトル文字数制限のテストケース更新
  - [ ] エラーメッセージ表示のテストケース更新
- [ ] プロンプト一覧画面のテスト修正
  - [ ] タイトル表示のテストケース更新
  - [ ] タグ表示のテストケース更新
  - [ ] 省略表示とツールチップのテストケース更新
- [ ] タグ入力のテスト修正
  - [ ] `tag_name`フィールドの修正
  - [ ] タグ文字数制限のテストケース更新

### 2. ビューの修正（優先度：中）
- [ ] プロンプト詳細画面
  - [ ] タイトル入力フィールドのID修正
  - [ ] エラーメッセージ表示の実装
- [ ] プロンプト一覧画面
  - [ ] タイトル省略表示の実装
  - [ ] タグ省略表示の実装
  - [ ] ツールチップの実装
- [ ] タグ管理画面
  - [ ] タグ入力フィールドのID修正
  - [ ] タグ一覧表示の改善

### 3. コントローラーの修正（優先度：中）
- [ ] `PromptsController`
  - [ ] タグ関連のパラメータ処理修正
  - [ ] バリデーションメッセージの改善
  - [ ] エラーハンドリングの強化
- [ ] `TagsController`
  - [ ] タグ作成処理の修正
  - [ ] タグ削除処理の改善

### 4. モデルの修正（優先度：低）
- [ ] `Prompt`モデル
  - [ ] バリデーションの見直し
  - [ ] タグ関連メソッドの整理
- [ ] `Tag`モデル
  - [ ] バリデーションの見直し
  - [ ] 文字数制限の調整

### 5. データベースの整理（優先度：低）
- [ ] インデックスの最適化
  - [ ] タグ検索用インデックスの追加
  - [ ] タイトル検索用インデックスの追加
- [ ] 不要なカラムの削除
  - [ ] 使用されていないカラムの特定
  - [ ] マイグレーションの作成と実行

## 備考
- タスクの完了期限は各タスクの実装状況に応じて設定
- 優先度はタスクの順序で示す（上から順に高優先度）
- 完了したタスクはチェックボックスをチェックし、必要に応じて完了日を記録
- システムテストの修正を最優先で行い、その後ビューとコントローラーの修正を並行して進める
- モデルとデータベースの修正は、他の修正が完了した後に行う


===


# 参考： CLIのエラー表記について

nakazawatarou@nakazawatarounoMacBook-Air prompty0302 % bundle exec rspec spec/system/
FFFFFFFFF

Failures:

  1) プロンプト詳細画面の文字数制限 タイトル入力 15文字以下のタイトル タイトルが正常に保存されること
     Failure/Error: fill_in "prompt_title", with: valid_title
     
     Capybara::ElementNotFound:
       Unable to find visible field "prompt_title" that is not disabled
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_nested_nested15_-_269.png

     
     # ./spec/system/prompt_detail_text_length_spec.rb:17:in `block (4 levels) in <top (required)>'

  2) プロンプト詳細画面の文字数制限 タイトル入力 15文字を超えるタイトル エラーメッセージが表示されること
     Failure/Error: fill_in "prompt_title", with: invalid_title
     
     Capybara::ElementNotFound:
       Unable to find visible field "prompt_title" that is not disabled
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_nested_nested15_2_-_490.png

     
     # ./spec/system/prompt_detail_text_length_spec.rb:29:in `block (4 levels) in <top (required)>'

  3) プロンプト一覧管理画面の文字数制限 タイトル表示 50文字以下のタイトル タイトルが完全に表示されること
     Failure/Error: expect(page).to have_content(short_title)
       expected to find text "これは50文字以下のタイトルです" in "Promptly\nプロンプト一覧\n長谷川 陽太\nプロンプト一覧\n並び替え\nプロンプトがまだありません。新しいプロンプトを追加してください。\n新しいプロンプト\nタイトル\nURL\nメモ\nタグ\n複数のタグはカンマ（,）で区切ってください\n既存タグ一覧\n0タグ"
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_2_nested_nested50_-_670.png

     
     # ./spec/system/prompt_list_text_length_spec.rb:18:in `block (4 levels) in <main>'

  4) プロンプト一覧管理画面の文字数制限 タイトル表示 50文字を超えるタイトル タイトルが省略表示され、ツールチップが表示されること
     Failure/Error: expect(page).to have_css('.truncate')
       expected to find css ".truncate" but there were no matches
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_2_nested_nested50_2_-_410.png

     
     # ./spec/system/prompt_list_text_length_spec.rb:29:in `block (4 levels) in <main>'

  5) プロンプト一覧管理画面の文字数制限 タグ表示 20文字以下のタグ タグが完全に表示されること
     Failure/Error: expect(page).to have_content(short_tag.name)
       expected to find text "短いタグ" in "Promptly\nプロンプト一覧\n井上 愛美\nプロンプト一覧\n並び替え\nプロンプトがまだありません。新しいプロンプトを追加してください。\n新しいプロンプト\nタイトル\nURL\nメモ\nタグ\n複数のタグはカンマ（,）で区切ってください\n既存タグ一覧\n0タグ"
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_2_nested_2_nested20_-_646.png

     
     # ./spec/system/prompt_list_text_length_spec.rb:44:in `block (4 levels) in <main>'

  6) プロンプト一覧管理画面の文字数制限 タグ表示 20文字を超えるタグ タグが省略表示され、ツールチップが表示されること
     Failure/Error: expect(page).to have_css('.truncate')
       expected to find css ".truncate" but there were no matches
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_2_nested_2_nested20_2_-_35.png

     
     # ./spec/system/prompt_list_text_length_spec.rb:55:in `block (4 levels) in <main>'

  7) プロンプト一覧管理画面の文字数制限 タグ表示 3つ以上のタグ 最初の3つのタグのみが表示され、残りは省略されること
     Failure/Error: expect(page).to have_content(tags[0].name)
       expected to find text "屈む" in "Promptly\nプロンプト一覧\n佐野 光\nプロンプト一覧\n並び替え\nプロンプトがまだありません。新しいプロンプトを追加してください。\n新しいプロンプト\nタイトル\nURL\nメモ\nタグ\n複数のタグはカンマ（,）で区切ってください\n既存タグ一覧\n0タグ"
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_2_nested_2_nested3_-3-_458.png

     
     # ./spec/system/prompt_list_text_length_spec.rb:68:in `block (4 levels) in <main>'

  8) タグの文字数制限 タグ名入力 30文字以下のタグ名 タグが正常に作成されること
     Failure/Error: fill_in "tag_name", with: valid_tag_name
     
     Capybara::ElementNotFound:
       Unable to find field "tag_name" that is not disabled
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_3_nested_nested30_-_730.png

     
     # ./spec/system/tag_text_length_spec.rb:16:in `block (4 levels) in <main>'

  9) タグの文字数制限 タグ名入力 30文字を超えるタグ名 タグは30文字に切り詰められて保存されること
     Failure/Error: fill_in "tag_name", with: invalid_tag_name
     
     Capybara::ElementNotFound:
       Unable to find field "tag_name" that is not disabled
     
     [Screenshot Image]: /Users/nakazawatarou/Documents/tarou/project/test03_bookmarkly/prompty03/prompty0302/tmp/capybara/failures_r_spec_example_groups_nested_3_nested_nested30_2_-30-_721.png

     
     # ./spec/system/tag_text_length_spec.rb:28:in `block (4 levels) in <main>'

Finished in 24.37 seconds (files took 1.41 seconds to load)
9 examples, 9 failures

Failed examples:

rspec ./spec/system/prompt_detail_text_length_spec.rb:15 # プロンプト詳細画面の文字数制限 タイトル入力 15文字以下のタイトル タイトルが正常に保存されること
rspec ./spec/system/prompt_detail_text_length_spec.rb:27 # プロンプト詳細画面の文字数制限 タイトル入力 15文字を超えるタイトル エラーメッセージが表示されること
rspec ./spec/system/prompt_list_text_length_spec.rb:16 # プロンプト一覧管理画面の文字数制限 タイトル表示 50文字以下のタイトル タイトルが完全に表示されること
rspec ./spec/system/prompt_list_text_length_spec.rb:27 # プロンプト一覧管理画面の文字数制限 タイトル表示 50文字を超えるタイトル タイトルが省略表示され、ツールチップが表示されること
rspec ./spec/system/prompt_list_text_length_spec.rb:42 # プロンプト一覧管理画面の文字数制限 タグ表示 20文字以下のタグ タグが完全に表示されること
rspec ./spec/system/prompt_list_text_length_spec.rb:53 # プロンプト一覧管理画面の文字数制限 タグ表示 20文字を超えるタグ タグが省略表示され、ツールチップが表示されること
rspec ./spec/system/prompt_list_text_length_spec.rb:66 # プロンプト一覧管理画面の文字数制限 タグ表示 3つ以上のタグ 最初の3つのタグのみが表示され、残りは省略されること
rspec ./spec/system/tag_text_length_spec.rb:14 # タグの文字数制限 タグ名入力 30文字以下のタグ名 タグが正常に作成されること
rspec ./spec/system/tag_text_length_spec.rb:26 # タグの文字数制限 タグ名入力 30文字を超えるタグ名 タグは30文字に切り詰められて保存されること

nakazawatarou@nakazawatarounoMacBook-Air prompty0302 % 




