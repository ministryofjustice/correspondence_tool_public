Rails.application.routes.draw do

resources :correspondence, only: [:new, :create] do
  get 'topic', action: 'step_topic', as: :step_topic, on: :collection
  #post 'about', action: 'about'
end

root to: 'correspondence#start'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
