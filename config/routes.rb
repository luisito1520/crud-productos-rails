Rails.application.routes.draw do
  # Páginas HTML (vistas) del CRUD de productos
  root "products#index"
  resources :products

  # API REST JSON del mismo CRUD
  namespace :api do
    resources :products, only: %i[index show create update destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
