require 'openai'

class OpenaiClient
  def initialize
    api_key = ENV['OPENAI_API_KEY']
    
    if api_key.blank?
      Rails.logger.warn "OpenAI APIキーが設定されていません。モックデータを使用します。"
      raise "OpenAI APIキーが設定されていません。.envファイルにOPENAI_API_KEYを設定してください。" 
    end
    
    begin
      @client = OpenAI::Client.new(access_token: api_key)
      Rails.logger.info "OpenAI APIクライアントが初期化されました。"
    rescue LoadError => e
      Rails.logger.error "OpenAI gemがインストールされていません: #{e.message}"
      raise "OpenAI gemがインストールされていません。'bundle add openai'を実行してインストールしてください。"
    rescue => e
      Rails.logger.error "OpenAI APIクライアント初期化エラー: #{e.message}"
      raise "OpenAI APIクライアント初期化エラー: #{e.message}"
    end
  end

  def generate_tag_suggestions(prompt, existing_tags, user_tags = [])
    # 既存タグが空の場合、モックタグを返す
    if existing_tags.empty?
      Rails.logger.warn "既存タグが空のため、モックタグを返します。"
      return generate_mock_tags
    end
    
    # プロンプトの内容を取得
    title = prompt.title.to_s
    notes = prompt.notes.to_s
    url = prompt.url.to_s
    current_tags = prompt.tags.pluck(:name).join(", ")
    
    # ユーザーが既に使用しているタグを優先
    prioritized_tags = user_tags.empty? ? "" : "【優先タグ（ユーザーが既に使用）】\n#{user_tags.join(", ")}\n\n"
    
    # APIリクエスト用のプロンプトを作成
    prompt_text = <<~PROMPT
      以下のプロンプト内容に最も関連する既存タグを5つ選んでください。
      【重要】必ず以下の「利用可能なタグ一覧」から選択し、新しいタグは絶対に作成しないでください。
      可能な限り「優先タグ」から選択し、それが適切でない場合のみ他のタグを選んでください。
      
      【プロンプト情報】
      タイトル: #{title}
      メモ: #{notes}
      #{"URL: #{url}" if url.present?}
      #{"現在のタグ: #{current_tags}" if current_tags.present?}
      
      #{prioritized_tags}【利用可能なタグ一覧】
      #{existing_tags.join(", ")}
      
      【レスポンス形式】
      - 「利用可能なタグ一覧」に含まれるタグのみを選択してください
      - 可能な限り「優先タグ」から選びます
      - カンマ区切りで出力してください
      - 数字や記号を追加しないでください
      - 新しいタグを作成しないでください
      - 利用可能なタグにないものは絶対に提案しないでください
      
      レスポンス:
    PROMPT
    
    Rails.logger.info "OpenAI APIにリクエスト送信中..."
    
    begin
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { 
              role: "system", 
              content: "あなたは既存タグの中から最適なものを選ぶアシスタントです。新しいタグは絶対に作成せず、与えられたタグリストの中からのみ選択してください。ユーザーが既に使用しているタグを優先して選択してください。"
            },
            { 
              role: "user", 
              content: prompt_text 
            }
          ],
          temperature: 0.2, # より決定論的な結果を得るために温度を下げる
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
      
      # 既存タグリストに含まれるもののみをフィルタリング
      valid_tags = tags.select { |tag| existing_tags.include?(tag) }
      
      # 有効なタグが見つからない場合はモックタグを使用
      if valid_tags.empty?
        Rails.logger.warn "有効なタグが見つからないため、モックタグを返します。"
        return generate_mock_tags
      end
      
      Rails.logger.info "生成されたタグ: #{valid_tags.inspect}"
      
      valid_tags
    rescue => e
      Rails.logger.error "OpenAI API呼び出し中にエラーが発生しました: #{e.message}"
      Rails.logger.info "モックタグを使用します。"
      generate_mock_tags
    end
  end
  
  private
  
  def generate_mock_tags
    # モックタグを返す
    mock_tags = ["プロンプト", "AI", "ChatGPT", "会話", "効率化"]
    Rails.logger.info "モックタグを生成しました: #{mock_tags.inspect}"
    mock_tags
  end
end 