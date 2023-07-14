Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: "merchant/items"
      end
      resources :items do
        resource :merchant, only: [:show], controller: "item/merchant"
      end
    end
  end
end
