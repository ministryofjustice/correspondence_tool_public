Rails.application.routes.draw do
  resources :correspondence, only: %i[new create]

  resources :feedback, only: %i[new create], path: "give-feedback", path_names: { new: "" }
  get "/give-feedback" => "feedback#new", as: "feedback"

  get "/correspondence" => "correspondence#topic"
  get "/correspondence/topic" => "correspondence#topic"
  get "/correspondence/search" => "correspondence#search"
  get "/correspondence/t_and_c" => "correspondence#t_and_c"
  get "/correspondence/authenticate/:uuid" => "correspondence#authenticate", as: "correspondence_authentication"
  get "/correspondence/confirmation/:uuid" => "correspondence#confirmation", as: "correspondence_confirmation"

  get "/accessibility" => "pages#accessibility"

  get "ping",           to: "heartbeat#ping", format: :json

  get "healthcheck",    to: "heartbeat#healthcheck",  as: "healthcheck", format: :json

  root to: "correspondence#start"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
