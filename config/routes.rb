Rails.application.routes.draw do
  # ユーザー認証関連のルート設定
  devise_for :users
  
  # 認証済みユーザーのルートパスをプロンプト一覧に設定
  authenticated :user do
    root to: 'prompts#index', as: :authenticated_root
  end
  
  # 非認証ユーザーのルートパスをログイン画面に設定
  devise_scope :user do
    root to: 'devise/sessions#new'
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # プロンプトのリソース定義
  resources :prompts do
    resources :tags, only: [:create, :destroy] do
      collection do
        get :suggest
      end
    end
  end
  
  # タグのリソース定義
  resources :tags, only: [:new, :create]
  
  # 古い編集URLへのアクセスを詳細ページにリダイレクト
  get '/prompts/:id/edit', to: redirect('/prompts/%{id}')
end
