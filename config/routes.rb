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

  # 認証が必要なルート
  constraints lambda { |request| request.session[:user_id].present? } do
    get '/dashboard', to: 'dashboard#index', as: :dashboard

    # 管理者用ルート
    constraints lambda { |request| User.find(request.session[:user_id]).admin? } do
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
        end
        collection do
          get :material_titles
        end
      end
    end

    # 生徒用ルート
    constraints lambda { |request| !User.find(request.session[:user_id]).admin? } do
      resources :student_homeworks, only: [:index, :show] do
        member do
          post :answer
          patch :update_answer
          delete 'delete_image/:image_id', action: :delete_image, as: :delete_image
        end
      end
    end
  end

  # ルートパスの設定
  root 'home#index'
end
