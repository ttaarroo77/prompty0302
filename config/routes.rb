Rails.application.routes.draw do
  root "prompts#index"
  
  resources :prompts do
    resources :tags, only: [:create, :destroy]
  end
end
