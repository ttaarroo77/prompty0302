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

  def generate_tag_suggestions(prompt, existing_tags, user_tags = [])
    # プロンプトの内容を取得
    title = prompt.title.to_s
    description = prompt.description.to_s
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
      説明: #{description}
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
      
      Rails.logger.info "生成されたタグ: #{valid_tags.inspect}"
      
      valid_tags
    rescue => e
      Rails.logger.error "OpenAI API呼び出し中にエラーが発生しました: #{e.message}"
      raise "OpenAI API呼び出しエラー: #{e.message}"
    end
  end
end 