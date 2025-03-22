require 'openai'

class OpenaiClient
  attr_reader :client

  def initialize
    @client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
  end

  # チャットメッセージを送信し、応答を取得する
  def chat(messages, model: nil, temperature: 0.7)
    model ||= ENV.fetch('OPENAI_MODEL', 'gpt-3.5-turbo')
    
    response = @client.chat(
      parameters: {
        model: model,
        messages: messages,
        temperature: temperature
      }
    )
    
    if response['error']
      Rails.logger.error("OpenAI API Error: #{response['error']}")
      return { error: response['error'] }
    end
    
    response.dig('choices', 0, 'message', 'content')
  end
end