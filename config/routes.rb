Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:index, :edit, :update]

  authenticated :user do
    root to: 'leave_applications#index', as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root to: 'devise/registrations#new', as: :unauthenticated_root
    end
  end

  resources :leave_applications, except: [:show] do
    member do
      get :reject
      patch :approve
      patch :update_rejection
    end

    collection do
      get :employee_leaves
      get :export_csv
    end
  end

  mount ActionCable.server => '/cable'
end
