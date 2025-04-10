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

  def suggest_tags(prompt, current_user = nil)
    return fallback_tags(prompt, current_user) unless @api_available

    begin
      Rails.logger.info "OpenAI APIを使用してタグを生成します: Prompt ID #{prompt.id}"
      
      # 既存のタグ一覧を取得
      existing_tags = get_existing_tags
      
      # 現在のユーザーが既に使用しているタグを取得
      user_tags = get_user_tags(current_user) if current_user
      
      # タグリストをログに出力（デバッグ用）
      Rails.logger.info "既存タグ一覧: #{existing_tags.inspect}"
      Rails.logger.info "ユーザータグ一覧: #{(user_tags || []).inspect}"
      
      # OpenAI APIを使用してタグを生成（既存タグの中から選択）
      tag_names = @openai_client.generate_tag_suggestions(prompt, existing_tags, user_tags || [])
      
      Rails.logger.info "OpenAI APIからのレスポンス: #{tag_names.inspect}"
      
      # 既存タグから一致するものを探す
      find_matching_tags(tag_names)
    rescue => e
      Rails.logger.error "OpenAI APIでエラーが発生しました: #{e.message}"
      Rails.logger.info "フォールバックメカニズムを使用します"
      
      fallback_tags(prompt, current_user)
    end
  end

  private

  def get_existing_tags
    # すべてのタグの名前を取得（prompt_idカラムは参照しない）
    all_tags = Tag.pluck(:name)
    
    # 重複を除去してソート
    all_tags.uniq.sort
  end

  def get_user_tags(user)
    return [] unless user
    
    # ユーザーが所有するプロンプトのIDを取得
    user_prompt_ids = Prompt.where(user_id: user.id).pluck(:id)
    
    # ユーザーのプロンプトに関連付けられたタグを取得
    user_tags = []
    
    # taggingsテーブル経由でタグを取得
    tag_ids = Tagging.where(prompt_id: user_prompt_ids).pluck(:tag_id).uniq
    user_tags = Tag.where(id: tag_ids).pluck(:name).uniq
    
    Rails.logger.info "ユーザータグ (#{user.email}): #{user_tags.inspect}"
    user_tags
  end

  def find_matching_tags(tag_names)
    tags = []
    tag_names.uniq.first(MAX_TAGS).each do |name|
      # 正規化された名前で既存タグを検索
      normalized_name = name.gsub(/[^\p{L}\p{N}\s_-]/u, '').strip
      next if normalized_name.blank?
      
      # 名前が21文字を超える場合は切り詰める（マイグレーションで制限されているため）
      normalized_name = normalized_name[0...21] if normalized_name.length > 21
      
      # 既存のタグを検索
      tag = Tag.find_by(name: normalized_name)
      
      # タグが見つからない場合は作成（これにより確実にタグが提案される）
      if tag.nil?
        Rails.logger.info "タグが見つからなかったため新規作成: #{normalized_name}"
        # 現在のユーザーIDがセッションから取得できない場合は最初の管理者を使用
        admin_user = User.find_by(admin: true) || User.first
        tag = Tag.create(name: normalized_name, user_id: admin_user.id)
      end
      
      tags << tag if tag && !tags.include?(tag)
    end
    
    Rails.logger.info "提案タグ: #{tags.map(&:name).join(', ')}"
    tags
  end

  def fallback_tags(prompt, current_user = nil)
    # フォールバックメカニズム: 既存タグの中から基本的なタグを選択
    existing_tags = get_existing_tags
    
    # ユーザーが既に使用しているタグを優先
    user_tags = get_user_tags(current_user) if current_user
    
    # ユーザータグ + 基本タグ + 既存タグの順で優先
    prioritized_tags = []
    prioritized_tags.concat(user_tags) if user_tags.present?
    prioritized_tags.concat(BASIC_TAGS & existing_tags) # 基本タグと既存タグの共通部分
    
    # 基本タグがなければ、基本タグを作成
    if prioritized_tags.empty? && BASIC_TAGS.any?
      admin_user = User.find_by(admin: true) || User.first
      BASIC_TAGS.each do |tag_name|
        next if tag_name.length > 21 # 名前の長さ制限
        tag = Tag.find_or_create_by(name: tag_name, user_id: admin_user.id)
        prioritized_tags << tag_name if tag.persisted?
      end
    end
    
    # 重複を除去
    prioritized_tags = prioritized_tags.uniq
    
    Rails.logger.info "フォールバックタグ: #{prioritized_tags.inspect}"
    
    # ユーザータグと基本タグから提案
    find_matching_tags(prioritized_tags)
  end
end