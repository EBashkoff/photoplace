class PhotosController < ApplicationController

  helper_method :photos, :album

  before_action :require_is_user

  def gallery

    gon.starting_image_index = params[:start] || 0

    @photos =
      if browser.device.mobile?
        gallery_photos(:small)
      else
        gallery_photos(:medium)
      end
  end

  def index
    photos
  end

  private

  def album
    @album ||= Album.find(params[:album_id])
  end

  def photos
    @photos ||= album.photos.select(:image, :order_index, :path).order(:order_index)
  end

  def gallery_photos(resolution)
    album
      .photos
      .order(:order_index)
      .map do |photo|
        OpenStruct.new(
          photo
            .slice(:title, :description)
            .merge(cf_path: photo.image.url(resolution))
        )
      end
  end

end
