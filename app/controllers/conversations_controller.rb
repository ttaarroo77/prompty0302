class ConversationsController < ApplicationController
  before_action :set_prompt
  
  def create
    @conversation = @prompt.conversations.new
    
    # OpenAI APIを使って会話を生成
    response = ConversationService.generate_response(@prompt, params[:message])
    
    @conversation.content = response[:content]
    @conversation.status = response[:status]
    
    if @conversation.save
      redirect_to prompt_path(@prompt, anchor: "conversation-#{@conversation.id}")
    else
      redirect_to @prompt, alert: '会話の生成に失敗しました'
    end
  end
  
  private
  
  def set_prompt
    @prompt = Prompt.find(params[:prompt_id])
  end
  
  def conversation_params
    params.permit(:message)
  end
end
