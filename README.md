# Prompty - プロンプト管理アプリ

## 利用可能なGitタグ

このプロジェクトには以下のタグが設定されています。特定の機能状態に戻りたい場合は、対応するタグをチェックアウトしてください。

### タグ一覧

- **tag-suggestion-improvement**: 
  タグ提案機能の基本実装。Turbo Frameを使用した非同期タグ提案機能です。
  ```
  git checkout tag-suggestion-improvement
  ```

- **inline-tag-suggestion**: 
  プロンプト詳細ページ内で直接タグ提案を表示する機能の実装。ページ遷移なしでタグ提案が可能になりました。
  ```
  git checkout inline-tag-suggestion
  ```

## タグの使い方

特定のタグの状態に戻る場合は、以下のコマンドを実行してください：

```bash
git checkout [タグ名]
```

例えば：

```bash
git checkout inline-tag-suggestion
```

これにより、そのタグが作成された時点のコードの状態に戻ります。
