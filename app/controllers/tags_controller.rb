class TagsController < ApplicationController
  before_action :set_prompt
  
  def create
    @tag = @prompt.tags.build(tag_params)
    
    if @tag.save
      redirect_to @prompt, notice: 'タグが追加されました'
    else
      redirect_to @prompt, alert: 'タグの追加に失敗しました。もう一度お試しください。'
    end
  end
  
  def destroy
    @tag = @prompt.tags.find(params[:id])
    @tag.destroy
    
    redirect_to @prompt, notice: 'タグが削除されました'
  end
  
  private
  
  def set_prompt
    @prompt = Prompt.find(params[:prompt_id])
  end
  
  def tag_params
    params.require(:tag).permit(:name)
  end
end 