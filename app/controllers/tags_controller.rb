class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.format.json? || request.xhr? }

  def create
    tag_name = tag_params[:name].strip
    
    if tag_name.present?
      # 既存のタグを検索または新規作成
      @tag = Tag.find_or_initialize_by(name: tag_name)
      
      if @tag.new_record?
        @tag.user = current_user
        @tag.save
      end
      
      # プロンプトにタグを関連付け
      unless @prompt.tags.include?(@tag)
        @prompt.tags << @tag
        flash[:notice] = "タグ「#{tag_name}」を追加しました。"
      else
        flash[:alert] = "タグ「#{tag_name}」は既に追加されています。"
      end
    else
      flash[:alert] = "タグ名を入力してください。"
    end
    
    # 提案タグのIDがある場合は保持
    tag_ids = []
    if params[:suggested_tag_ids].present?
      tag_ids = params[:suggested_tag_ids].is_a?(Array) ? params[:suggested_tag_ids] : params[:suggested_tag_ids].split(',')
    end
    
    redirect_to prompt_path(@prompt, suggested_tag_ids: tag_ids)
  end

  def destroy
    @tag = Tag.find(params[:id])
    
    # タグとプロンプトの関連付けを解除
    @prompt.tags.delete(@tag)
    
    flash[:notice] = "タグ「#{@tag.name}」を削除しました。"
    
    # 提案タグのIDがある場合は保持
    tag_ids = []
    if params[:suggested_tag_ids].present?
      tag_ids = params[:suggested_tag_ids].is_a?(Array) ? params[:suggested_tag_ids] : params[:suggested_tag_ids].split(',')
    end
    
    redirect_to prompt_path(@prompt, suggested_tag_ids: tag_ids)
  end

  def suggest
    Rails.logger.info "タグ提案処理を開始します: Prompt #{@prompt.id}"
    begin
      service = TagSuggestionService.new
      @suggested_tags = service.suggest_tags(@prompt)
      
      Rails.logger.info "生成されたタグ名: #{@suggested_tags.map(&:name).inspect}"
      
      # 提案されたタグのIDをセッションに保存
      session[:suggested_tag_ids] = @suggested_tags.map(&:id).compact
      Rails.logger.info "セッションに保存したタグID: #{session[:suggested_tag_ids].inspect}"
      
      # プロンプト詳細ページにリダイレクト
      redirect_to prompt_path(@prompt, suggested_tag_ids: session[:suggested_tag_ids]), notice: 'タグが提案されました。' and return
    rescue => e
      Rails.logger.error "タグ提案エラー: #{e.message}"
      error_message = e.message.include?('API key') ? 'APIキーが設定されていません' : e.message
      redirect_to @prompt, alert: "タグの提案に失敗しました: #{error_message}" and return
    end
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:prompt_id])
    # 他のユーザーのプロンプトへのアクセスを防止
    unless @prompt.user_id == current_user.id
      flash[:alert] = "アクセス権限がありません。"
      redirect_to prompts_path
    end
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
