class PromptsController < ApplicationController
  before_action :set_prompt, only: [:show, :update, :generate_tags, :destroy]
  
  def index
    @prompts = Prompt.all.order(created_at: :desc)
    @prompt = Prompt.new
  end
  
  def create
    @prompt = Prompt.new(prompt_params)
    
    if @prompt.save
      redirect_to @prompt, notice: 'プロンプトが作成されました'
    else
      @prompts = Prompt.all.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end
  
  def show
    # 会話関連の処理をコメントアウト
    # @conversations = @prompt.conversations.order(created_at: :desc)
    # @conversation = Conversation.new(prompt: @prompt)
  end
  
  def update
    if @prompt.update(prompt_params)
      redirect_to @prompt, notice: 'プロンプトが更新されました'
    else
      # @conversations = @prompt.conversations.order(created_at: :desc)
      render :show
    end
  end
  
  def destroy
    @prompt.destroy
    redirect_to root_path, notice: 'プロンプトが削除されました'
  end
  
  def generate_tags
    # プロンプト内容からタグを生成
    tags = TagGeneratorService.generate_for_prompt(@prompt)
    
    if tags.present?
      redirect_to @prompt, notice: 'タグが生成されました'
    else
      redirect_to @prompt, alert: 'タグの生成に失敗しました。もう一度お試しください。'
    end
  end
  
  private
  
  def set_prompt
    @prompt = Prompt.find(params[:id])
  end
  
  def prompt_params
    params.require(:prompt).permit(:title, :url, :description)
  end
end
