class PromptsController < ApplicationController
  require_relative '../models/ai'
  
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  before_action :check_prompt_owner, only: [:show, :edit, :update, :destroy]

  def index
    @prompt = Prompt.new
    # ベースのクエリを作成
    query = Prompt.where(user_id: current_user.id)
    
    # タグフィルターの適用
    if params[:tag].present?
      query = query.joins(:tags).where(tags: { name: params[:tag] })
    end
    
    # 検索フィルターの適用
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      query = query.where("title LIKE ? OR description LIKE ?", search_term, search_term)
                   .or(query.joins(:tags).where("tags.name LIKE ?", search_term))
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
    
    # 最終結果を取得
    @prompts = query.distinct
    
    # 必要な変数の初期化
    @user_tags = {}
    @all_tags_for_display = []
    @total_tag_count = 0
    @suggested_tags = []
    
    # ユーザーに関連するタグを取得
    user_prompt_ids = Prompt.where(user_id: current_user.id).pluck(:id)
    
    # ユーザーのプロンプトに紐づくタグを取得
    tags_with_count = Tag.joins(:taggings)
                         .where(taggings: { prompt_id: user_prompt_ids })
                         .group(:name)
                         .count
    
    # タグの表示用データを準備
    @user_tags = tags_with_count
    @all_tags_for_display = @user_tags.keys
    @total_tag_count = @all_tags_for_display.size
    
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
    @prompt = Prompt.find(params[:id])
    
    begin
      # タグ提案の取得処理
      if params[:suggested].present?
        # 既存のタグ提案をクリア
        ::AI::TagSuggestion.where(prompt_id: @prompt.id).delete_all
        
        # モックタグを生成して保存
        mock_tags = [
          { name: "自己PR", confidence_score: 0.9 },
          { name: "プロフィール", confidence_score: 0.8 },
          { name: "ビジネス", confidence_score: 0.7 },
          { name: "マーケティング", confidence_score: 0.6 },
          { name: "ポートフォリオ", confidence_score: 0.5 },
          { name: "実績", confidence_score: 0.4 },
          { name: "デザイン", confidence_score: 0.3 }
        ]
        
        mock_tags.each do |tag|
          ::AI::TagSuggestion.create(
            prompt_id: @prompt.id,
            name: tag[:name],
            confidence_score: tag[:confidence_score],
            applied: false
          )
        end
        
        flash[:notice] = 'AIがタグを生成しました'
      end
      
      # タグ提案を取得
      @suggested_tags = ::AI::TagSuggestion.where(prompt_id: @prompt.id).order(confidence_score: :desc)
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
    @prompt = Prompt.new(prompt_params)
    @prompt.user = current_user

    respond_to do |format|
      if @prompt.save
        format.html { redirect_to prompts_path, notice: "プロンプトが作成されました。" }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|

      
      if @prompt.update(prompt_params)
        format.html { redirect_to prompt_path(@prompt), notice: "プロンプトが更新されました。" }
        format.json { render :show, status: :ok, location: @prompt }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @prompt.destroy
    redirect_to prompts_path, notice: 'プロンプトが削除されました。'
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end

  def check_prompt_owner
    unless @prompt.user_id == current_user.id
      redirect_to prompts_path, alert: '他のユーザーのプロンプトにはアクセスできません。'
    end
  end

  def prompt_params
    params.require(:prompt).permit(:title, :description, :url)
  end
end
