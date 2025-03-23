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
  end

  def edit
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
      redirect_to @prompt, notice: 'プロンプトが更新されました。'
    else
      render :edit, status: :unprocessable_entity
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
