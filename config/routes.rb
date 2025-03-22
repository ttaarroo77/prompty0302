Rails.application.routes.draw do
  resources :prompts, only: [:index, :show, :create, :update, :destroy] do
    # タグ生成機能
    member do
      post :generate_tags
    end
    
    resources :conversations, only: [:create]
    resources :tags, only: [:create, :destroy]
  end
  
  # デフォルトのルートをプロンプト一覧ページに設定（ID指定なし）
  root to: 'prompts#index'
end
