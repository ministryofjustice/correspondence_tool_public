Rails.application.routes.draw do

resources :correspondence, only: [:new, :create]

resources :feedback, only: [:new, :create]

get '/correspondence' => 'correspondence#topic'
get '/correspondence/topic' => 'correspondence#topic'
get '/correspondence/search' => 'correspondence#search'
get '/correspondence/t_and_c' => 'correspondence#t_and_c'
get '/correspondence/authenticate/:uuid' => 'correspondence#authenticate', as: 'correspondence_authentication'
get '/correspondence/confirmation/:uuid' => 'correspondence#confirmation', as: 'correspondence_confirmation'

get '/feedback' => 'feedback#new'

get 'ping',           to: 'heartbeat#ping', format: :json

get 'healthcheck',    to: 'heartbeat#healthcheck',  as: 'healthcheck', format: :json

root to: 'correspondence#start'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
