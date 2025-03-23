class TagsController < ApplicationController
  before_action :set_prompt

  def create
    @tag = @prompt.tags.build(tag_params)
    
    if @tag.save
      # タグ提案を保持するためのセッション変数を確認
      session[:suggested_tag_ids] ||= []
      
      respond_to do |format|
        format.html {
          # HTMLリクエストの場合は通常のリダイレクト
          redirect_to prompt_path(@prompt, suggested_tag_ids: session[:suggested_tag_ids]), notice: 'タグが追加されました。'
        }
        format.json {
          # JSONリクエストの場合は成功レスポンスを返す
          render json: { 
            success: true, 
            tag_id: @tag.id, 
            tag_name: @tag.name,
            prompt_id: @prompt.id,
            message: 'タグが追加されました。'
          }
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to @prompt, alert: 'タグの追加に失敗しました。'
        }
        format.json {
          render json: { 
            success: false, 
            errors: @tag.errors.full_messages,
            message: 'タグの追加に失敗しました。'
          }, status: :unprocessable_entity
        }
      end
    end
  end

  def destroy
    @tag = @prompt.tags.find(params[:id])
    @tag.destroy
    
    # タグ提案を保持するためのセッション変数を確認
    session[:suggested_tag_ids] ||= []
    
    respond_to do |format|
      format.html {
        redirect_to prompt_path(@prompt, suggested_tag_ids: session[:suggested_tag_ids]), notice: 'タグが削除されました。'
      }
      format.json {
        render json: { 
          success: true, 
          message: 'タグが削除されました。'
        }
      }
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
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
