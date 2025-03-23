require 'openai'

class OpenaiClient
  def initialize
    api_key = ENV['OPENAI_API_KEY']
    
    raise "OpenAI APIキーが設定されていません。.envファイルにOPENAI_API_KEYを設定してください。" if api_key.blank?
    
    @client = OpenAI::Client.new(access_token: api_key)
  rescue LoadError => e
    Rails.logger.error "OpenAI gemがインストールされていません: #{e.message}"
    raise "OpenAI gemがインストールされていません。'bundle add openai'を実行してインストールしてください。"
  end

  def generate_tag_suggestions(prompt)
    # プロンプトの内容を取得
    title = prompt.title.to_s
    description = prompt.description.to_s
    url = prompt.url.to_s
    current_tags = prompt.tags.pluck(:name).join(", ")
    
    # APIリクエスト用のプロンプトを作成
    prompt_text = <<~PROMPT
      以下のプロンプト内容に合うタグを10個程度提案してください。タグは日本語か英語の単語またはフレーズで、SEOに効果的なものを選んでください。
      
      タイトル: #{title}
      説明: #{description}
      #{"URL: #{url}" if url.present?}
      #{"現在のタグ: #{current_tags}" if current_tags.present?}
      
      レスポンスは次の形式で返してください:
      tag1, tag2, tag3, ...
    PROMPT
    
    Rails.logger.info "OpenAI APIにリクエスト送信中..."
    
    begin
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt_text }],
          temperature: 0.5,
          max_tokens: 150
        }
      )
      
      if response["error"].present?
        Rails.logger.error "OpenAI APIエラー: #{response["error"]["message"]}"
        raise "OpenAI APIエラー: #{response["error"]["message"]}"
      end
      
      # レスポンスからタグを抽出
      content = response.dig("choices", 0, "message", "content").to_s
      
      # カンマ区切りのタグリストを配列に変換
      tags = content.split(/,\s*/).map(&:strip).reject(&:empty?)
      
      # 余分な記号や修飾を削除
      tags = tags.map { |tag| tag.gsub(/^[#*"'`]|[#*"'`]$/, '').strip }
      
      Rails.logger.info "生成されたタグ: #{tags.inspect}"
      
      tags
    rescue => e
      Rails.logger.error "OpenAI API呼び出し中にエラーが発生しました: #{e.message}"
      raise "OpenAI API呼び出しエラー: #{e.message}"
    end
  end
end 