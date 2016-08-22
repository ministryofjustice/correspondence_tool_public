Rails.application.routes.draw do

resources :correspondence, only: [:new, :create] do
  get 'topic', action: 'step_topic', as: :step_topic, on: :collection
  #post 'about', action: 'about'
  get 'message', action: 'step_message', as: :step_message, on: :collection
  get 'name', action: 'step_name', as: :step_name, on: :collection
  get 'reply', action: 'step_reply', as: :step_reply, on: :collection
end

root to: 'correspondence#start'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
