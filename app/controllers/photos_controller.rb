class PhotosController < ApplicationController

  helper_method :photos, :album

  before_action :require_is_user

  def gallery

    gon.starting_image_index = 0

    @photos =
      if browser.device.mobile?
        album.photos.small.sort_by(&:filename)
      else
        album.photos.medium.sort_by(&:filename)
      end
  end

  def index
    photos
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

  def album
    @album ||= Album.find(params[:album_id])
  end

  def photos
    @photos ||= Photo.joins(album: :collection).select(:image, :album_id, :name, :path).where(album_id: params[:album_id])
  end


end
