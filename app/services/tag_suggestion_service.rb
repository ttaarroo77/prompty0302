class TagSuggestionService
  MAX_TAGS = 10
  BASIC_TAGS = ["プロンプト", "AI", "ChatGPT", "会話", "効率化"]

  def initialize
    begin
      @openai_client = OpenaiClient.new
      @api_available = true
    rescue => e
      Rails.logger.error "OpenAIクライアント初期化エラー: #{e.message}"
      @api_available = false
    end
  end

  def suggest_tags(prompt)
    return fallback_tags(prompt) unless @api_available

    begin
      Rails.logger.info "OpenAI APIを使用してタグを生成します: Prompt ID #{prompt.id}"
      
      # OpenAI APIを使用してタグを生成
      tag_names = @openai_client.generate_tag_suggestions(prompt)
      
      Rails.logger.info "OpenAI APIからのレスポンス: #{tag_names.inspect}"
      
      # 生成されたタグから既存のタグを探すか作成する
      create_or_find_tags(tag_names, prompt)
    rescue => e
      Rails.logger.error "OpenAI APIでエラーが発生しました: #{e.message}"
      Rails.logger.info "フォールバックメカニズムを使用します"
      
      fallback_tags(prompt)
    end
  end

  private

  def fallback_tags(prompt)
    # フォールバックメカニズム: プロンプトの内容から基本的なタグを生成
    fallback_tag_names = suggest_tags_from_content(prompt)
    create_or_find_tags(fallback_tag_names, prompt)
  end

  def create_or_find_tags(tag_names, prompt)
    tags = []
    tag_names.uniq.first(MAX_TAGS).each do |name|
      # 特殊文字を削除し、空白をアンダースコアに変換
      normalized_name = name.gsub(/[^\p{L}\p{N}\s_-]/u, '').strip
      
      next if normalized_name.blank?
      
      # 既存のタグ（グローバルタグ）を優先的に使用
      tag = Tag.where(prompt_id: nil).find_by(name: normalized_name)
      
      # グローバルタグが見つからない場合は、新しいタグを作成
      tag ||= Tag.new(name: normalized_name)
      
      tags << tag unless tags.include?(tag)
    end
    
    Rails.logger.info "提案タグ: #{tags.map(&:name).join(', ')}"
    tags
  end

  def suggest_tags_from_content(prompt)
    tags = BASIC_TAGS.dup
    
    # プロンプトのタイトルと説明から単語を抽出
    content = "#{prompt.title} #{prompt.description}"
    
    # 日本語の単語を抽出（簡易的な実装）
    japanese_words = content.scan(/[\p{Han}\p{Hiragana}\p{Katakana}]{2,}/u).uniq
    
    # 英語の単語を抽出
    english_words = content.scan(/\b[a-zA-Z]{4,}\b/).uniq
    
    # 抽出した単語を追加
    tags += japanese_words.first(5) + english_words.first(5)
    
    # URLからドメイン名を抽出
    if prompt.url.present?
      begin
        domain = URI.parse(prompt.url).host
        domain = domain.sub(/^www\./, '') if domain
        tags << domain if domain
      rescue URI::InvalidURIError
        # 無効なURLは無視
      end
    end
    
    tags.uniq.first(MAX_TAGS)
  end
end