Rails.application.routes.draw do
get "/api/v1/merchants/find_all", to: "api/v1/merchants/search#index"
get "/api/v1/items/find", to: "api/v1/item/search#show"

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
