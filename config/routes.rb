Rails.application.routes.draw do

resources :correspondence, only: [:new, :create]

resources :feedback, only: [:new, :create]

get '/correspondence' => 'correspondence#new'

get '/feedback' => 'feedback#new'

get 'ping',           to: 'heartbeat#ping', format: :json

get 'healthcheck',    to: 'heartbeat#healthcheck',  as: 'healthcheck', format: :json

root to: 'correspondence#start'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
