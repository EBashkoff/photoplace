class PhotosController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album

  before_action :require_is_user

  def index
    @album = Collection.find(params[:collection_name]).albums.detect do |album|
      album.name == params[:album_name]
    end

    @photos = album.photos.large
    render :index1
  end

  def show
    respond_to do |format|
      format.jpg do
        filename = File.join(Rails.application.secrets.base_photo_path, "#{params[:path]}.jpg")
        "************* IN PHOTO CONTROLLER PHOTO FILENAME #{filename}"
        send_data(IO.read(filename), { type: "image/jpg", disposition: 'inline' })
      end
    end
  end

end
