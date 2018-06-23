module Admin
  class UploadsController < ApplicationController

    MAX_UPLOAD_SIZE = 12 * 1000 * 1000

    before_action :require_is_admin

    helper_method :album_infos

    def new
      gon.create_album_url       = admin_uploads_create_url
      gon.update_album_url       = admin_uploads_update_url
      gon.upload_file_url        = admin_uploads_upload_file_url
      gon.after_upload_files_url = admin_uploads_after_upload_files_url
      gon.max_upload_size        = MAX_UPLOAD_SIZE
    end

    def create
      album.update!(album_params)
      render json: { path: album.path }
    rescue => e
      Rails.logger.error("IN #{self.class}: #{e.message}")
      render json:   { statusText: "Could not create upload location on server" },
             status: :internal_server_error
    end

    def update
      album.update(album_params)
      render json: { success: true }
    end

    def after_upload_files
      album.add_photo_order_indexes
      render json: { success: true, album: album.path, album_id: album.id }

    rescue => e
      Rails.logger.error("IN #{self.class}: #{e.message}")
      render json:   { statusText: "Could not update photo indexes", success: false },
             status: :internal_server_error
    end

    def upload_file
      photo.image = params[:file]
      photo.path = File.join(album.collection.name, params[:album_path], params[:filename])
      photo.save!
      render json: { success: true, filename: params["filename"] }

    rescue => e
      e.backtrace.each {|f| puts f}
      Rails.logger.error("IN #{self.class}: #{e.message}")
      render json:   { statusText: "Could not create file on server", success: false },
             status: :internal_server_error
    end

    private

    def album
      @album ||=
        Album.find_or_create_by(path: album_path) do |album|
          album.order_index = collection.albums.count + 1
        end
    end

    def album_infos
      @album_infos ||=
        [['<Image Gallery Root Folder>', '', { "data-name" => '', "data-description" => '' }]] +
          Album.all.map do |album|
            [
              album.path,
              album.path,
              { "data-name" => album.title, "data-description" => album.description }
            ]
          end.sort_by(&:first)
    end

    def album_params
      unless action_name == 'upload_file'
        params.require(:album).permit(:path, :title, :description, :collection_id)
      end
    end

    def album_path
      album_params&.fetch(:path) || params[:album_path]
    end

    def photo
      @photo ||= album.photos.find_or_initialize_by(image: params[:filename])
    end

    def collection
      @collection ||= Collection.find_by(album_params[:collection_id])
    end

  end
end
