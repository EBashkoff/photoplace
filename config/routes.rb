Rails.application.routes.draw do
  resources :users
  resources :collections, only: :index
  get 'photos/*path', to: 'photos#show'
  get '/album/:collection_name/:album_name',
      controller: :photos,
      action:     :index,
      as:         :album

  get '/map/:collection_name/:album_name',
      controller: :maps,
      action:     :index,
      as:         :map

  resource :session, :only => [:show, :create]
  get    'login'  => 'sessions#new'
  delete 'logout' => 'sessions#destroy'

end
