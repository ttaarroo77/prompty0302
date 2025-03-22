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
    @suggested_tags = []
    
    begin
      service = TagSuggestionService.new(@prompt)
      suggested_tag_names = service.suggest_tags
      @suggested_tags = service.find_matching_tags(suggested_tag_names)
    rescue => e
      Rails.logger.error "タグ提案エラー: #{e.message}"
      # エラーが発生しても@suggested_tagsは空の配列のままなので、
      # 「提案するタグが見つかりませんでした」というメッセージが表示される
    end
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @prompt }
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
