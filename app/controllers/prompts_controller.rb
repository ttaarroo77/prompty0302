class PromptsController < ApplicationController
  require_relative '../models/ai'
  
  before_action :authenticate_user!
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  before_action :check_prompt_owner, only: [:show, :edit, :update, :destroy]

  def index
    @prompt = Prompt.new
    
    # 検索フィルターの適用
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      
      # IDでフィルタリングする方法を使用
      title_desc_ids = Prompt.where(user_id: current_user.id)
                            .where("title LIKE ? OR notes LIKE ?", search_term, search_term)
                            .pluck(:id)
      
      tag_ids = Prompt.where(user_id: current_user.id)
                      .joins(:tags)
                      .where("tags.name LIKE ?", search_term)
                      .pluck(:id)
      
      # IDの配列を結合して重複を排除
      combined_ids = (title_desc_ids + tag_ids).uniq
      
      # マッチしたIDのプロンプトを取得
      @prompts = Prompt.where(id: combined_ids)
      
      # タグフィルター
      if params[:tag].present?
        @prompts = @prompts.joins(:tags).where(tags: { name: params[:tag] }).distinct
      end
      
      # ソート
      case params[:sort]
      when 'title_asc'
        @prompts = @prompts.order(title: :asc)
      when 'title_desc'
        @prompts = @prompts.order(title: :desc)
      when 'created_asc'
        @prompts = @prompts.order(created_at: :asc)
      else
        @prompts = @prompts.order(created_at: :desc)
      end
    else
      # 検索条件がない場合の処理
      query = Prompt.where(user_id: current_user.id)
      
      # タグフィルターの適用
      if params[:tag].present?
        query = query.joins(:tags).where(tags: { name: params[:tag] }).distinct
      end
      
      # ソートの適用
      case params[:sort]
      when 'title_asc'
        query = query.order(title: :asc)
      when 'title_desc'
        query = query.order(title: :desc)
      when 'created_asc'
        query = query.order(created_at: :asc)
      when 'created_desc', nil
        query = query.order(created_at: :desc)
      end
      
      @prompts = query
    end
    
    # 必要な変数の初期化
    @user_tags = {}
    @all_tags_for_display = []
    @total_tag_count = 0
    @suggested_tags = []
    
    # ユーザーに関連するタグを取得
    user_prompt_ids = Prompt.where(user_id: current_user.id).pluck(:id)
    Rails.logger.debug "User prompt IDs: #{user_prompt_ids.inspect}"
    
    # ユーザーのプロンプトに紐づくタグを取得（taggings経由）
    tags_with_count = Tag.joins(:taggings)
                         .where(taggings: { prompt_id: user_prompt_ids })
                         .select("tags.name, COUNT(taggings.id) as count")
                         .group("tags.name")
                         .order("count DESC")
    Rails.logger.debug "Tags with count: #{tags_with_count.inspect}"
    
    # タグの表示用データを準備
    @user_tags = {}
    @all_tags_for_display = []
    
    tags_with_count.each do |tag|
      @user_tags[tag.name] = tag.count
      @all_tags_for_display << tag.name
    end
    
    @total_tag_count = @all_tags_for_display.size
    Rails.logger.debug "All tags for display: #{@all_tags_for_display.inspect}"
    Rails.logger.debug "Total tag count: #{@total_tag_count}"
    
    # 現在の検索条件
    @search_filters = {
      search: params[:search],
      tag: params[:tag],
      sort: params[:sort]
    }
  
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    # set_promptで@promptが設定されている前提
    return unless @prompt
    
    begin
      # タグ提案の取得処理
      if params[:suggested].present?
        # 既存のタグ提案をクリア
        ::AI::TagSuggestion.where(prompt_id: @prompt.id).delete_all
        
        begin
          # TagSuggestionServiceを使用してタグを提案
          service = TagSuggestionService.new
          tag_suggestions = service.suggest_tags(@prompt, current_user)
          
          Rails.logger.info "TagSuggestionServiceからの提案タグ: #{tag_suggestions.map(&:name).inspect}"
          
          # 提案されたタグがある場合、AI::TagSuggestionモデルに保存
          if tag_suggestions.present?
            tag_suggestions.each_with_index do |tag, index|
              confidence = 1.0 - (index * 0.1) # 単純な信頼度スコア（最初が最高）
              ::AI::TagSuggestion.create(
                prompt_id: @prompt.id,
                name: tag.name,
                confidence_score: confidence,
                applied: false
              )
            end
            flash[:notice] = 'AIがタグを生成しました'
          else
            # モックタグを生成して保存
            mock_tags = [
              { name: "自己PR", confidence_score: 0.9 },
              { name: "プロフィール", confidence_score: 0.8 },
              { name: "ビジネス", confidence_score: 0.7 },
              { name: "マーケティング", confidence_score: 0.6 },
              { name: "ポートフォリオ", confidence_score: 0.5 }
            ]
            
            mock_tags.each do |tag|
              ::AI::TagSuggestion.create(
                prompt_id: @prompt.id,
                name: tag[:name],
                confidence_score: tag[:confidence_score],
                applied: false
              )
            end
            
            flash[:notice] = 'AIがタグを生成しました (モックデータ)'
          end
        rescue => e
          Rails.logger.error "タグ提案サービスエラー: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          
          # エラー時はモックデータを使用
          mock_tags = [
            { name: "自己PR", confidence_score: 0.9 },
            { name: "プロフィール", confidence_score: 0.8 },
            { name: "ビジネス", confidence_score: 0.7 },
            { name: "マーケティング", confidence_score: 0.6 },
            { name: "ポートフォリオ", confidence_score: 0.5 }
          ]
          
          mock_tags.each do |tag|
            ::AI::TagSuggestion.create(
              prompt_id: @prompt.id,
              name: tag[:name],
              confidence_score: tag[:confidence_score],
              applied: false
            )
          end
          
          flash[:alert] = "タグ提案中にエラーが発生しましたが、モックデータを使用しました: #{e.message}"
        end
      end
      
      # タグ提案を取得
      @suggested_tags = ::AI::TagSuggestion.where(prompt_id: @prompt.id).order(confidence_score: :desc)
      Rails.logger.debug "提案タグ数: #{@suggested_tags.size}"
    rescue => e
      # エラーが発生した場合はログに出力し、デフォルト値を設定
      Rails.logger.error "Error with tag suggestions: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @suggested_tags = []
    end
    
    # デバッグモードで詳細情報をログに出力
    Rails.logger.debug "Prompt ID: #{@prompt.id}, Title: #{@prompt.title}"
    Rails.logger.debug "User: #{@prompt.user.email}" if @prompt.user.present?
  rescue => e
    Rails.logger.error "Error in show action: #{e.message}"
    redirect_to prompts_path, alert: "プロンプトの表示中にエラーが発生しました。"
  end

  def edit
    # 編集画面は不要なので詳細ページにリダイレクト
    redirect_to @prompt
  end

  def create
    @prompt = current_user.prompts.build(prompt_params)
    
    # 一時変数にタグを保存
    @tag_list = params[:tags].present? ? params[:tags].split(',').map(&:strip) : []

    respond_to do |format|
      if @prompt.save
        # タグの処理
        tag_errors = []
        if @tag_list.present?
          @tag_list.each do |tag_name|
            next if tag_name.blank?
            
            # タグ名が長すぎる場合は切り詰める（30文字まで）
            tag_name = tag_name[0...30] if tag_name.length > 30
            
            tag = Tag.find_or_initialize_by(name: tag_name)
            if tag.new_record?
              tag.user = current_user
              unless tag.save
                tag_errors << "タグ「#{tag_name}」: #{tag.errors.full_messages.join(', ')}"
                next
              end
            end
            Tagging.create(prompt: @prompt, tag: tag)
          end
        end
        
        notice_message = 'プロンプトを作成しました'
        notice_message += "（警告: #{tag_errors.join('; ')}）" if tag_errors.any?
        
        format.html { redirect_to @prompt, notice: notice_message }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # 一時変数にタグを保存
    @tag_list = params[:tags].present? ? params[:tags].split(',').map(&:strip) : []
    
    respond_to do |format|
      if @prompt.update(prompt_params)
        # タグの処理
        tag_errors = []
        
        # 既存のタグを削除
        @prompt.taggings.destroy_all
        
        # 新しいタグを追加
        if @tag_list.present?
          @tag_list.each do |tag_name|
            next if tag_name.blank?
            
            # タグ名が長すぎる場合は切り詰める（30文字まで）
            tag_name = tag_name[0...30] if tag_name.length > 30
            
            tag = Tag.find_or_initialize_by(name: tag_name)
            if tag.new_record?
              tag.user = current_user
              unless tag.save
                tag_errors << "タグ「#{tag_name}」: #{tag.errors.full_messages.join(', ')}"
                next
              end
            end
            Tagging.create(prompt: @prompt, tag: tag)
          end
        end
        
        notice_message = 'プロンプトを更新しました'
        notice_message += "（警告: #{tag_errors.join('; ')}）" if tag_errors.any?
        
        format.html { redirect_to @prompt, notice: notice_message }
        format.json { 
          render json: { 
            success: true, 
            prompt: { 
              id: @prompt.id,
              title: @prompt.title,
              notes: @prompt.notes,
              url: @prompt.url,
              tags: @prompt.tags.map { |tag| { id: tag.id, name: tag.name } }
            }, 
            message: notice_message 
          }, status: :ok 
        }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @prompt.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # 関連するAI::TagSuggestionレコードを直接削除
    begin
      ActiveRecord::Base.connection.execute("DELETE FROM ai_tag_suggestions WHERE prompt_id = #{@prompt.id}")
    rescue => e
      # エラーがあっても続行
      Rails.logger.error "Failed to delete ai_tag_suggestions: #{e.message}"
    end
    
    # プロンプトを削除
    @prompt.destroy
    
    respond_to do |format|
      format.html { redirect_to prompts_url, notice: 'プロンプトを削除しました' }
      format.json { head :no_content }
    end
  end

  private

  def set_prompt
    # current_userがnilの場合はログインページにリダイレクト
    unless current_user
      redirect_to new_user_session_path, alert: 'この操作を行うにはログインが必要です。'
      return
    end
    
    @prompt = current_user.prompts.find_by(id: params[:id])
    
    # プロンプトが見つからない場合はリダイレクト
    unless @prompt
      redirect_to prompts_path, alert: 'プロンプトが見つかりませんでした。'
    end
  end

  def check_prompt_owner
    # set_promptでnilチェックを行うようになったので簡略化
    return if @prompt.nil?
    
    unless @prompt.user_id == current_user.id
      redirect_to prompts_path, alert: '他のユーザーのプロンプトにはアクセスできません。'
    end
  end

  def prompt_params
    params.require(:prompt).permit(:title, :content, :notes, :url)
  end
end
