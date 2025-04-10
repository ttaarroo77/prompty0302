class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_prompt, only: [:create, :destroy]
  skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.format.json? || request.xhr? }

  def create
    tag_name = tag_params[:name].strip
    
    if tag_name.present?
      begin
        # 既存のタグを検索または新規作成
        @tag = Tag.find_or_initialize_by(name: tag_name[0...21]) # 21文字に制限（スキーマに合わせる）
        
        # タグが既にプロンプトに関連付けられているかを確認
        if @prompt.tags.exists?(name: @tag.name)
          flash[:alert] = "タグ「#{@tag.name}」は既に追加されています。"
          redirect_to prompt_path(@prompt, suggested_tag_ids: params[:suggested_tag_ids])
          return
        end
        
        if @tag.new_record?
          @tag.user = current_user
          @tag.save!
        end
        
        # taggingsテーブルに関連付けがないことを再確認
        if Tagging.exists?(prompt_id: @prompt.id, tag_id: @tag.id)
          flash[:alert] = "タグ「#{@tag.name}」は既に追加されています。"
          redirect_to prompt_path(@prompt, suggested_tag_ids: params[:suggested_tag_ids])
          return
        else
          tagging = Tagging.new(prompt: @prompt, tag: @tag)
          if tagging.save
            flash[:notice] = "タグ「#{@tag.name}」を追加しました。"
          else
            flash[:alert] = "タグの追加に失敗しました: #{tagging.errors.full_messages.join(', ')}"
          end
        end
      rescue => e
        Rails.logger.error "タグ作成エラー: #{e.message}"
        flash[:alert] = "タグの追加に失敗しました：#{e.message}"
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
    begin
      @tag = Tag.find(params[:id])
      
      # taggingsテーブルからの関連付けを削除
      tagging = Tagging.find_by(prompt_id: @prompt.id, tag_id: @tag.id)
      if tagging&.destroy
        respond_to do |format|
          format.html { redirect_to @prompt, notice: "タグ '#{@tag.name}' が削除されました。" }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to @prompt, alert: "タグの削除に失敗しました。" }
          format.json { render json: { error: "タグの削除に失敗しました。" }, status: :unprocessable_entity }
        end
      end
    rescue => e
      Rails.logger.error "タグ削除エラー: #{e.message}"
      respond_to do |format|
        format.html { redirect_to @prompt, alert: "タグの削除に失敗しました: #{e.message}" }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
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
