Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :games, only: [:show, :new, :create, :edit, :update]
  resources :positions, only: [:show, :new, :create, :edit, :update]
  resources :challenges, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      get 'respond'
    end
  end

  get 'pass_and_play', to: 'games#pass_and_play', as: :pass_and_play
  patch 'move', to: 'games#move'
  root to: 'pages#home'
end
