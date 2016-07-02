Rails.application.routes.draw do
  root to: "collections#index"

  resources :users
  resources :collections, only: :index
  get 'photos/*path', to: 'photos#show'
  get '/album_gallery/:collection_name/:album_name',
      controller: :photos,
      action:     :gallery,
      as:         :album_gallery

  get '/album_thumbs/:collection_name/:album_name',
      controller: :photos,
      action:     :index,
      as:         :album_thumbs

  get '/downloads/:collection_name/:album_name(.:format)',
      controller: :downloads,
      action:     :index,
      as:         :downloads

  get '/map/:collection_name/:album_name',
      controller: :maps,
      action:     :index,
      as:         :map

  resource :session, :only => [:show, :create]
  get    'login'  => 'sessions#new'
  delete 'logout' => 'sessions#destroy'

end
