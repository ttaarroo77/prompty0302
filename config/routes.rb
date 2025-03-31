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
  # edit アクションを除外（詳細ページで編集機能を提供）
  resources :prompts, except: [:edit] do
    resources :tags, only: [:create, :destroy] do
      collection do
        get :suggest
      end
    end
  end
  
  # 古い編集URLへのアクセスを詳細ページにリダイレクト
  get '/prompts/:id/edit', to: redirect('/prompts/%{id}')
end
