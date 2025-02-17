Rails.application.routes.draw do
  resources :correspondence, only: %i[new create]

  resources :feedback, only: %i[new create], path: "give-feedback", path_names: { new: "" }
  get "/give-feedback" => "feedback#new", as: "feedback"

  get "/cookies/:consent", to: "cookies#update"
  resource :cookies, only: %i[show update]

  get "/correspondence" => "correspondence#topic"
  get "/correspondence/topic" => "correspondence#topic"
  get "/correspondence/search" => "correspondence#search"
  get "/correspondence/t_and_c" => "correspondence#t_and_c"
  get "/correspondence/authenticate/:uuid" => "correspondence#authenticate", as: "correspondence_authentication"
  get "/correspondence/confirmation/:uuid" => "correspondence#confirmation", as: "correspondence_confirmation"

  get "/accessibility" => "pages#accessibility"

  get "ping", to: "heartbeat#ping", format: :json
  get "healthcheck", to: "heartbeat#healthcheck", as: "healthcheck", format: :json

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_error"

  root to: "correspondence#start"
end
