class MapsController < ApplicationController

  attr_reader :album, :geotaggedfiles
  helper_method :album, :google_maps_key, :nice_latitude, :nice_longitude,
                :geotaggedfiles

  before_action :require_is_user

  def index
    @geotaggedfiles = album.photos.select do |photo|
      photo.latitude && photo.longitude
    end.sort_by(&:order_index).reduce({}) do |m, photo|
      info = {
        small_photo_url: photo.image.url(:small),
        thumb_photo_url: photo.image.url(:thumb),
        latitude:        photo.latitude,
        longitude:       photo.longitude,
        description:     photo.description,
        filename:        photo.filename,
        filetype:        photo.filetype,
        orientation:     photo.orientation
      }
      m.merge({ photo.image => info })
    end

    gon.geotaggedfiles   = geotaggedfiles
    gon.browser          = browser.name
    gon.pin_icon_img     = pin_icon_images

    render :index
  end

  private

  def album
    @album ||= Album.find_by(id: params[:album_id])
  end

  def nice_latitude(fileinfo)
    return "" unless (latitude = fileinfo[:latitude])
    "#{latitude > 0.0 ? 'N' : 'S'} #{latitude.abs.round(6)}"
  end

  def nice_longitude(fileinfo)
    return "" unless (longitude = fileinfo[:longitude])
    "#{longitude > 0.0 ? 'E' : 'W'} #{longitude.abs.round(6)}"
  end

  def google_maps_key
    Rails.application.secrets.google_maps_key
  end

  def device_size
    return "small" if params["shorthead"]
    ""
  end

  def pin_icon_images
    %i(small medium large).reduce({}) do |m, size|
      m.merge(
        {
          size.to_s => ActionController::Base.helpers.asset_path("icon6#{size.to_s[0]}.png")
        }
      )
    end
  end

end
