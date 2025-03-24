class PromptsController < ApplicationController
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]
  before_action :check_prompt_owner, only: [:show, :edit, :update, :destroy]

  def index
    @prompt = Prompt.new
    @prompts = Prompt.where(user_id: current_user.id)
                    .includes(:tags)  # タグを事前に読み込み
    
    # 検索機能の追加
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @prompts = @prompts.left_joins(:tags)
      
      # データベースアダプタに応じて適切な検索メソッドを使用
      if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
        @prompts = @prompts.where("prompts.title ILIKE ? OR prompts.description ILIKE ? OR tags.name ILIKE ?", 
                                 search_term, search_term, search_term)
      else
        @prompts = @prompts.where("LOWER(prompts.title) LIKE ? OR LOWER(prompts.description) LIKE ? OR LOWER(tags.name) LIKE ?", 
                                 search_term, search_term, search_term)
      end
      
      @prompts = @prompts.distinct
    end
    
    # タグによるフィルタリング
    if params[:tag].present?
      @prompts = @prompts.joins(:tags).where(tags: { name: params[:tag] })
    end

    # ソート機能の追加
    case params[:sort]
    when 'title_asc'
      @prompts = @prompts.order(title: :asc)
    when 'title_desc'
      @prompts = @prompts.order(title: :desc)
    when 'created_asc'
      @prompts = @prompts.order(created_at: :asc)
    when 'created_desc'
      @prompts = @prompts.order(created_at: :desc)
    else
      @prompts = @prompts.order(created_at: :desc) # デフォルトは作成日時の降順
    end

    # タグ関連の処理
    # 現在のユーザーのプロンプトに関連付けられたタグのみを取得
    user_prompts = Prompt.where(user_id: current_user.id).pluck(:id)
    
    # 現在のユーザーが使用しているタグのみを取得
    @user_tags = Tag.where(prompt_id: user_prompts)
                    .group(:name)
                    .count
    
    # 表示用のタグリスト（ユーザーが使用しているタグのみ）
    @all_tags_for_display = @user_tags.keys
    
    # タグの総数
    @total_tag_count = @user_tags.keys.size

    # Turbo Streamsのリクエストに対応
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @prompt = Prompt.find(params[:id])
    # 一時的にタグ提案を無効化
    @suggested_tags = []
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
    # params.require(:prompt).permit(:title, :description, :url, :attachment)
  end
end
