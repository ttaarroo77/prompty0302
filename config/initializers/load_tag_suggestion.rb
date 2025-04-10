# AIモジュールとTagSuggestionクラスを明示的に読み込む
Rails.application.config.to_prepare do
  require_dependency Rails.root.join('app/models/ai/tag_suggestion').to_s
end 