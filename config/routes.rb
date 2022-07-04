Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :games, only: [:show, :new, :create, :edit, :update] do
    collection do
      get 'guest'
    end
  end
  resources :positions, only: [:show, :new, :create, :edit, :update]
  resources :challenges, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      get 'respond'
    end
  end
  # Defines the root path route ("/")
  root to: 'pages#home'
end
