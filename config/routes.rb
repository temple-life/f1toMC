FtCampaigner::Application.routes.draw do
  resources :user_sessions, :only => [:new, :create, :destroy]
  get "user_sessions/callback"
  match 'signin', :to => 'user_sessions#new'
  match 'signout', :to => 'user_sessions#destroy'

  resource :account, :only => [:edit, :update]

  get   "synchronize/new/step_1",       :to => "synchronize#step_1"
  post  "synchronize/new/save_step_1",  :to => "synchronize#save_step_1"
  get   "synchronize/new/step_2",       :to => "synchronize#step_2"
  post  "synchronize",                  :to => 'synchronize#create'
  get   "synchronize/get_attributes"

  resources :lists, :only => [:index, :show] do
    resources :campaigns, :only => [:index, :show]
  end

  match 'home', :to => "home#index"
  root :to => 'home#index'
end
