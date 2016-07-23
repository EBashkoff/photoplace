Rails.application.routes.draw do
  root to: "collections#index"

  resources :users
  resources :collections, only: :index
  get 'photos/*path',
      controller: :photos,
      action:     :show

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

  get '/uploads/new',
      controller: :uploads,
      action:     :new,
      as:         :uploads

  get '/uploads/full_res_files',
      controller: :uploads,
      action:     :index,
      as:         :uploads_full_res_files

  post '/uploads',
      controller: :uploads,
      action:     :create,
      as:         :uploads_create_folders

  post '/upload_file',
      controller: :uploads,
      action:     :upload_file,
      as:         :uploads_upload_file

  post '/uploads/set_album_meta',
      controller: :uploads,
      action:     :set_album_meta,
      as:         :uploads_set_album_meta

  post '/uploads/resize_file',
      controller: :uploads,
      action:     :resize_file,
      as:         :uploads_resize_file

  get '/map/:collection_name/:album_name',
      controller: :maps,
      action:     :index,
      as:         :map

  resource :session, :only => [:show, :create]
  get 'login',
      controller: :sessions,
      action:     :new

  delete 'logout',
         controller: :sessions,
         action:     :destroy

  get '/google/manifest.json',
      controller: :google_manifest,
      action:     :index,
      as:         :google_manifest

end
