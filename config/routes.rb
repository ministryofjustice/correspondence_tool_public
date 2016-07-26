Rails.application.routes.draw do

resources :correspondence, only: [:new, :create]

get '/correspondence' => 'correspondence#new'

root to: 'correspondence#new'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
