Rails.application.routes.draw do
  # resources :applications, :path => "api/v1/applicaitons/", param: :token do
  resources :applications, param: :token do
    resources :chats, param: :number do
      get "messages/search", to: "messages#search"
      resources :messages, param: :number
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
