class PhotosController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album, :collection_name

  before_action :require_is_user

  def gallery
    @album = Collection.find(collection_name).albums.detect do |album|
      album.name == params[:album_name]
    end
    gon.starting_image_index =
      if params[:filename]
        album.photo_index(params[:filename])
      else
        0
      end
    @photos = album.photos.large
  end

  def index
    @album  = Collection.find(collection_name).albums.detect do |album|
      album.name == params[:album_name]
    end
    @photos = album.photos.thumb.sort_by(&:filename)
  end

  def show
    respond_to do |format|
      format.jpg do
        filename = File.join(Rails.root, Rails.application.secrets.base_photo_path, "#{params[:path]}.jpg")
        send_file filename, type: "image/jpeg", disposition: 'inline'
      end
    end
  end

  private

  def collection_name
    params[:collection_name]
  end

end
