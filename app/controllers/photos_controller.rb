class PhotosController < ApplicationController

  attr_reader :photos
  helper_method :photos

  def index
    @photos = Collection.find(params[:collection_name]).albums.detect do |album|
      album.name == params[:album_name]
    end.photos.large
    render :index
  end

  def show
    respond_to do |format|
      format.jpg do
        filename = File.join(Rails.application.secrets.base_photo_path, "#{params[:path]}.jpg")
        send_data(IO.read(filename), { type: "image/jpg", disposition: 'inline' })
      end
    end
  end

end
