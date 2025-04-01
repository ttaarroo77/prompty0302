# config/initializers/autoload.rb
Rails.application.config.to_prepare do
  require_relative '../../app/models/ai'
end