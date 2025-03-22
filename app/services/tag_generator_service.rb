class TagGeneratorService
  def self.generate_for_prompt(prompt)
    # OpenAI APIクライアントを初期化
    client = OpenaiClient.new
    
    # プロンプトの情報からシステムメッセージを作成
    system_message = {
      role: 'system',
      content: "あなたはプロンプトからタグを生成する専門家です。与えられたプロンプトの内容を分析し、関連するタグを5つ程度提案してください。タグは単語もしくは短いフレーズで、日本語で回答してください。タグのみを返し、説明は不要です。"
    }
    
    # プロンプト情報をユーザーメッセージとして作成
    prompt_content = "タイトル: #{prompt.title}\n説明: #{prompt.description}"
    user_message = {
      role: 'user',
      content: prompt_content
    }
    
    # OpenAI APIに送信するメッセージ
    messages = [system_message, user_message]
    
    begin
      # APIを呼び出してタグを取得
      response = client.chat(messages)
      
      if response.is_a?(Hash) && response[:error]
        Rails.logger.error("OpenAI API Error: #{response[:error]}")
        return []
      end
      
      # レスポンスをタグのリストに変換
      tags = parse_tags_from_response(response)
      
      # 既存のタグをクリア
      prompt.tags.destroy_all
      
      # 新規タグを作成
      created_tags = []
      tags.each do |tag_name|
        tag = prompt.tags.create(name: tag_name)
        created_tags << tag if tag.persisted?
      end
      
      created_tags
    rescue => e
      Rails.logger.error("TagGeneratorService Error: #{e.message}")
      []
    end
  end
  
  private
  
  def self.parse_tags_from_response(response)
    # レスポンスを行ごとに分割
    lines = response.to_s.split(/[\n,、]/)
    
    # 空行を削除し、各行をトリミング
    tags = lines.map(&:strip)
      .reject(&:empty?)
      .map { |line| line.gsub(/^[-•*・]/, '').strip } # 箇条書き記号を削除
      .reject { |line| line.length > 20 } # 長すぎるタグを除外
      .uniq
      .take(10) # 最大10個まで
    
    tags
  end
end