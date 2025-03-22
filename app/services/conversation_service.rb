class ConversationService
  def self.generate_response(prompt, message)
    # OpenAI APIクライアントを初期化
    client = OpenaiClient.new
    
    # プロンプトの情報からシステムメッセージを作成
    system_message = {
      role: 'system',
      content: "あなたは「#{prompt.title}」に関する質問に答えるアシスタントです。以下の情報に基づいて回答してください：\n\n#{prompt.description}"
    }
    
    # ユーザーのメッセージを作成
    user_message = {
      role: 'user',
      content: message
    }
    
    # OpenAI APIに送信するメッセージ
    messages = [system_message, user_message]
    
    begin
      # APIを呼び出して応答を取得
      response = client.chat(messages)
      
      if response.is_a?(Hash) && response[:error]
        # エラー発生時はエラーメッセージを返す
        Rails.logger.error("OpenAI API Error: #{response[:error]}")
        return {
          content: "申し訳ありません。エラーが発生しました：#{response[:error]}",
          status: 'failed'
        }
      end
      
      # レスポンスを整形
      user_content = "ユーザー: #{message}"
      assistant_response = "AIアシスタント: #{response}"
      
      {
        content: "#{user_content}\n\n#{assistant_response}",
        status: 'completed'
      }
    rescue => e
      Rails.logger.error("ConversationService Error: #{e.message}")
      {
        content: "ユーザー: #{message}\n\nAIアシスタント: 申し訳ありません。エラーが発生しました。後でもう一度お試しください。",
        status: 'failed'
      }
    end
  end
end 