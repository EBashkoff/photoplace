Rails.application.routes.draw do
  root to: "collections#index"

  namespace :admin do
    resources :users
    resources :collections, only: %i[index show new create edit update]
    resources :albums, only: %i[index show edit update]

    get '/uploads/new',
        controller: :uploads,
        action:     :new,
        as:         :uploads

    post '/uploads',
         controller: :uploads,
         action:     :create,
         as:         :uploads_create

    put '/uploads',
         controller: :uploads,
         action:     :update,
         as:         :uploads_update

    post '/upload_file',
         controller: :uploads,
         action:     :upload_file,
         as:         :uploads_upload_file

    post '/after_upload_files',
         controller: :uploads,
         action:     :after_upload_files,
         as:         :uploads_after_upload_files
  end

  resources :collections, only: :index

  get 'photos/*path',
      controller: :photos,
      action:     :show

  get '/album_gallery/:album_id(.:format)',
      controller: :photos,
      action:     :gallery,
      as:         :album_gallery

  get '/album_thumbs/:album_id(.:format)',
      controller: :photos,
      action:     :index,
      as:         :album_thumbs

  get '/downloads/:album_id(.:format)',
      controller: :downloads,
      action:     :index,
      as:         :downloads

  get '/map/:album_id(.:format)',
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
