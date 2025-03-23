class TagsController < ApplicationController
  before_action :set_prompt

  def create
    @tag = @prompt.tags.build(tag_params)
    
    if @tag.save
      redirect_to @prompt, notice: 'タグが追加されました。'
    else
      redirect_to @prompt, alert: 'タグの追加に失敗しました。'
    end
  end

  def destroy
    @tag = @prompt.tags.find(params[:id])
    @tag.destroy
    
    redirect_to @prompt, notice: 'タグが削除されました。'
  end

  def suggest
    Rails.logger.info "タグ提案開始: Prompt #{@prompt.id}"
    begin
      service = TagSuggestionService.new
      @suggested_tags = service.suggest_tags(@prompt)
      
      Rails.logger.info "生成されたタグ名: #{@suggested_tags.map(&:name).join(', ')}"
      
      respond_to do |format|
        format.turbo_stream
        format.html { render :suggest }
      end
    rescue => e
      Rails.logger.error "タグ提案エラー: #{e.message}"
      flash.now[:alert] = "タグの提案に失敗しました: #{e.message.include?('API key') ? 'APIキーが設定されていません' : e.message}"
      @suggested_tags = []
      
      respond_to do |format|
        format.turbo_stream
        format.html { render :suggest }
      end
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
