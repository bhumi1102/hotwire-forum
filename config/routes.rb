Rails.application.routes.draw do
  resources :categories
  root to: "main#index"
  get 'main/index'
  devise_for :users
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :discussions, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    resources :posts, only: [:create, :show, :edit, :update, :destroy], module: :discussions
  
    collection do
      get "category/:id", to: "categories/discussions#index", as: :category
    end
  end


end
