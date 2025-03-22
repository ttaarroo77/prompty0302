class OpenaiClient
  def initialize
    # APIキーの設定 (本番環境では環境変数から読み込むべき)
    @api_key = 'sk-your-api-key'
  end

  def chat(messages)
    # この実装ではAPIは実際には呼び出さずにモックレスポンスを返します
    # 実際の実装では、HTTPクライアントを使用してOpenAI APIを呼び出します
    
    if messages.any? { |m| m[:role] == 'system' && m[:content].include?('タグを生成') }
      # タグ生成のモックレスポンス
      return "プロフィール最適化\nココナラ\nアドバイス\n受注率向上\n集客"
    else
      # 通常の会話のモックレスポンス
      user_message = messages.find { |m| m[:role] == 'user' }
      return "テストの成功、おめでとうございます！努力が実を結びました。この成果をしっかりと楽しんでください。次のステップに向けた素晴らしいスタートです。成功を祝って、リラックスしたり、好きなことをしてから次の課題に取り組むのもいいでしょう。また、新たなチャレンジへのモチベーションにもつながることでしょう。引き続き頑張ってください！"
    end
  end
end 