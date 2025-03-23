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
      
      # 既存のタグ一覧を取得
      existing_tags = get_existing_tags
      
      # OpenAI APIを使用してタグを生成（既存タグの中から選択）
      tag_names = @openai_client.generate_tag_suggestions(prompt, existing_tags)
      
      Rails.logger.info "OpenAI APIからのレスポンス: #{tag_names.inspect}"
      
      # 既存タグから一致するものを探す
      find_matching_tags(tag_names)
    rescue => e
      Rails.logger.error "OpenAI APIでエラーが発生しました: #{e.message}"
      Rails.logger.info "フォールバックメカニズムを使用します"
      
      fallback_tags(prompt)
    end
  end

  private

  def get_existing_tags
    # スタンドアロンタグとプロンプトに紐づくタグを取得
    standalone_tags = Tag.where(prompt_id: nil).pluck(:name)
    prompt_tags = Tag.where.not(prompt_id: nil).pluck(:name)
    
    # 重複を除去してソート
    (standalone_tags + prompt_tags).uniq.sort
  end

  def find_matching_tags(tag_names)
    tags = []
    tag_names.uniq.first(MAX_TAGS).each do |name|
      # 正規化された名前で既存タグを検索
      normalized_name = name.gsub(/[^\p{L}\p{N}\s_-]/u, '').strip
      next if normalized_name.blank?
      
      # 既存のタグを検索（スタンドアロンタグを優先）
      tag = Tag.where(prompt_id: nil).find_by(name: normalized_name)
      tag ||= Tag.where.not(prompt_id: nil).find_by(name: normalized_name)
      
      tags << tag if tag && !tags.include?(tag)
    end
    
    Rails.logger.info "提案タグ: #{tags.map(&:name).join(', ')}"
    tags
  end

  def fallback_tags(prompt)
    # フォールバックメカニズム: 既存タグの中から基本的なタグを選択
    existing_tags = get_existing_tags
    fallback_tag_names = (BASIC_TAGS & existing_tags) # 既存タグとの共通部分のみを使用
    find_matching_tags(fallback_tag_names)
  end
end