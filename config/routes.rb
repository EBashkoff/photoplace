Rails.application.routes.draw do
  resources :users
  resources :collections, only: :index
  get 'photos/*path', to: 'photos#show'
  get '/album/:collection_name/:album_name',
      controller: :photos,
      action:     :index,
      as:         :album
end
