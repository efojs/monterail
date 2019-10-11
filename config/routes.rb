Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :events do
        member do
          post "book/:amount", to: "events#book"
        end
      end
      resources :orders, except: :index do
        member do
          get "tickets"
          post "pay/:token", to: "orders#pay"
        end
      end
    end
  end
end
