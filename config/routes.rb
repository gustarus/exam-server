Rails.application.routes.draw do
  root to: 'home#index'
  get '/not_allowed' => 'home#not_allowed'

  devise_for :user
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  namespace :api do
    scope '/quiz' do
      get '/list' => 'quiz#list'
      get '/extended/:token' => 'quiz#extended'
      get '/extended_by_session/:session_token' => 'quiz#extended_by_session'
    end

    scope '/session' do
      post '/create' => 'session#create'
      get '/view/:token' => 'session#view'
      put '/start/:token' => 'session#start'
      put '/pause/:token' => 'session#pause'
      put '/finish/:token' => 'session#finish'
    end

    scope '/form' do
      post '/create' => 'form#create'
      put '/update/:token' => 'form#update'
      get '/view/:token' => 'form#view'
    end
  end
end
