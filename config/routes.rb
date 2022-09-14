Rails.application.routes.draw do
  root to: "main#index"
  get 'main/index'
  devise_for :users
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :discussions, only: [:index, :new, :create, :edit, :update]


end
