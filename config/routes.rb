Rails.application.routes.draw do
  root to: "main#index"
  get 'main/index'
  devise_for :users
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :discussions, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :posts, only: [:create], module: :discussions
  end


end
