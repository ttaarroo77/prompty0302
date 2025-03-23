class PromptsController < ApplicationController
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]

  def index
    @prompts = Prompt.all.order(created_at: :desc)
    @prompt = Prompt.new
    @all_tags = Tag.all.order(:name)
    @standalone_tags = Tag.where(prompt_id: nil).order(:name)
  end

  def show
    @tag = Tag.new
    @suggested_tags = []
    
    if params[:suggested] == 'true'
      # タグ提案ボタンが押された場合
      begin
        service = TagSuggestionService.new
        @suggested_tags = service.suggest_tags(@prompt)
        Rails.logger.info "プロンプト詳細ページでタグ提案: #{@suggested_tags.map(&:name).inspect}"
      rescue => e
        Rails.logger.error "タグ提案エラー (詳細ページ): #{e.message}"
        flash.now[:alert] = "タグの提案に失敗しました: #{e.message.include?('API key') ? 'APIキーが設定されていません' : e.message}"
        @suggested_tags = []
      end
    elsif params[:suggested_tag_ids].present?
      # タグ追加/削除後のリダイレクトで提案タグIDが渡された場合
      tag_ids = params[:suggested_tag_ids].is_a?(Array) ? params[:suggested_tag_ids] : params[:suggested_tag_ids].split(',')
      @suggested_tags = Tag.where(id: tag_ids)
      Rails.logger.info "パラメータから復元したタグ提案: #{@suggested_tags.map(&:name).inspect}"
    elsif session[:suggested_tag_ids].present?
      # セッションに保存されたタグIDがある場合
      @suggested_tags = Tag.where(id: session[:suggested_tag_ids])
      Rails.logger.info "セッションから復元したタグ提案: #{@suggested_tags.map(&:name).inspect}"
    end
  end

  def edit
    # 編集画面は不要なので詳細ページにリダイレクト
    redirect_to @prompt
  end

  def create
    @prompt = Prompt.new(prompt_params)

    if @prompt.save
      redirect_to @prompt, notice: 'プロンプトが作成されました。'
    else
      @prompts = Prompt.all
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @prompt.update(prompt_params)
      respond_to do |format|
        format.html {
          redirect_to @prompt, notice: 'プロンプトが更新されました。'
        }
        format.json {
          render json: {
            success: true,
            prompt: {
              id: @prompt.id,
              title: @prompt.title,
              url: @prompt.url,
              description: @prompt.description
            },
            message: 'プロンプトが更新されました。'
          }
        }
        format.any {
          if request.xhr?
            render json: {
              success: true,
              prompt: {
                id: @prompt.id,
                title: @prompt.title,
                url: @prompt.url,
                description: @prompt.description
              },
              message: 'プロンプトが更新されました。'
            }
          else
            redirect_to @prompt, notice: 'プロンプトが更新されました。'
          end
        }
      end
    else
      error_messages = @prompt.errors.full_messages.join(', ')
      
      respond_to do |format|
        format.html {
          render :show, status: :unprocessable_entity
        }
        format.json {
          render json: {
            success: false,
            errors: @prompt.errors.full_messages,
            message: "プロンプトの更新に失敗しました: #{error_messages}"
          }, status: :unprocessable_entity
        }
        format.any {
          if request.xhr?
            render json: {
              success: false,
              errors: @prompt.errors.full_messages,
              message: "プロンプトの更新に失敗しました: #{error_messages}"
            }, status: :unprocessable_entity
          else
            render :show, status: :unprocessable_entity
          end
        }
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

  def prompt_params
    params.require(:prompt).permit(:title, :url, :description)
  end
end
