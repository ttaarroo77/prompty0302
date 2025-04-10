# AIモジュールとTagSuggestionクラスの読み込み問題を解決
Rails.application.config.to_prepare do
  # AIモジュールが定義されていない場合は定義する
  unless Object.const_defined?('AI')
    module AI; end
  end

  # TagSuggestionクラスが定義されていない場合、空のクラスを定義
  unless AI.const_defined?('TagSuggestion')
    AI::TagSuggestion = Class.new(ApplicationRecord) do
      belongs_to :prompt
      validates :name, presence: true
    end
  end
end 