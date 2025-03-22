require 'openai'

class OpenaiClient
  def initialize
    api_key = ENV['OPENAI_API_KEY']
    
    if api_key.blank? || api_key == 'your_api_key_here'
      raise "OpenAI APIキーが設定されていません。.envファイルでOPENAI_API_KEYを設定してください。"
    end
    
    @client = OpenAI::Client.new(
      access_token: api_key,
      uri_base: ENV['OPENAI_URI_BASE'] || 'https://api.openai.com',
      request_timeout: 240
    )
  end

  def generate_tag_suggestions(title, description, url, current_tags = [])
    begin
      prompt = generate_prompt(title, description, url, current_tags)
      
      response = @client.chat(
        parameters: {
          model: ENV['OPENAI_MODEL'] || 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: 'あなたはタグ提案の専門家です。与えられた情報から最適なタグを提案してください。' },
            { role: 'user', content: prompt }
          ],
          temperature: 0.5,
          max_tokens: 1000
        }
      )
      
      return process_response(response)
    rescue => e
      Rails.logger.error "OpenAI API エラー: #{e.message}"
      return []
    end
  end

  private

  def generate_prompt(title, description, url, current_tags)
    <<~PROMPT
    以下の情報から最適なタグを提案してください。
    
    【タイトル】
    #{title}
    
    【説明】
    #{description}
    
    #{url.present? ? "【URL】\n#{url}\n\n" : ""}
    #{current_tags.any? ? "【現在のタグ】\n#{current_tags.join(', ')}\n\n" : ""}
    
    【提案対象の既存タグ一覧】
    #{Tag.where(prompt_id: nil).order(:name).pluck(:name).join(', ')}
    
    【条件】
    - 上記の既存タグ一覧から選んでください
    - 内容に最も関連性の高いものを5-10個選択してください
    - JSONフォーマットで返してください：{"suggested_tags": ["タグ1", "タグ2", ...]}
    PROMPT
  end

  def process_response(response)
    return [] unless response.dig('choices', 0, 'message', 'content')
    
    content = response.dig('choices', 0, 'message', 'content')
    
    # JSONを抽出
    json_match = content.match(/\{.*\}/m)
    return [] unless json_match
    
    begin
      json = JSON.parse(json_match[0])
      return json['suggested_tags'] || []
    rescue JSON::ParserError
      Rails.logger.error "JSON解析エラー: #{content}"
      return []
    end
  end
end 