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
    Rails.logger.info "タグ提案処理を開始します: Prompt #{@prompt.id}"
    begin
      service = TagSuggestionService.new
      @suggested_tags = service.suggest_tags(@prompt)
      
      Rails.logger.info "生成されたタグ名: #{@suggested_tags.map(&:name).inspect}"
      
      # Turbo Streamではなく、プロンプト詳細ページにリダイレクトしてフラッシュメッセージで結果を表示
      redirect_to @prompt, notice: 'タグが提案されました。' and return
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
