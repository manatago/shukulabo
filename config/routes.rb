Rails.application.routes.draw do
  # Omniauth
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/logout', to: 'sessions#destroy', as: :logout
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # ダッシュボード
  get '/dashboard', to: 'dashboard#index', as: :dashboard

  # 管理者用ルート
  namespace :admin do
    resources :users, only: [:index, :edit, :update] do
      member do
        patch :toggle_admin
        post :impersonate
      end
      collection do
        delete :stop_impersonating
      end
    end
    resources :account_groups
    resources :login_histories, only: [:index]
  end
  
  # 教材管理
  resources :teaching_materials do
    collection do
      get :search
    end
  end
  
  resources :tags, except: [:show]
  
  # 宿題管理
  resources :homeworks do
    member do
      get :answers
      patch 'answers/:answer_id/grade/:teaching_material_id', action: :grade_answer, as: :grade_answer
      post :add_material
      delete :remove_material
    end
  end

  # 生徒用ルート
  resources :student_homeworks, only: [:index, :show] do
    member do
      post :answer
      patch :update_answer
      delete 'delete_image/:image_id', action: :delete_image, as: :delete_image
    end
  end

  # ルートパスの設定
  root 'home#index'
end
