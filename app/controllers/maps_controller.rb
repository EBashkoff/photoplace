class MapsController < ApplicationController
  attr_reader :album, :geotaggedfiles
  helper_method :album, :google_maps_key, :small_photo_path, :thumb_photo_path,
                :nice_latitude, :nice_longitude, :geotaggedfiles

  before_action :require_is_user

  def index
    @album = Collection.find(params[:collection_name]).albums.detect do |album|
      album.name == params[:album_name]
    end

    photos          = album.photos.small
    @geotaggedfiles = photos.select do |photo|
      photo.latitude && photo.longitude
    end.reduce({}) do |m, photo|
      info = {
        latitude:    photo.latitude,
        longitude:   photo.longitude,
        description: photo.description,
        filename:    photo.filename,
        filetype:    photo.filetype,
        orientation: photo.orientation
      }
      m.merge({ photo.filename => info })
    end

    gon.geotaggedfiles   = geotaggedfiles
    gon.small_photo_path = small_photo_path
    gon.device_size      = device_size

    render :index
  end

  private

  def small_photo_path
    File.join("/", album.app_path, "images", "small")
  end

  def thumb_photo_path
    File.join("/", album.app_path, "images", "thumb")
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

end
