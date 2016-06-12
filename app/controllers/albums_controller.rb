require 'zip'

class DownloadsController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album, :collection_name

  before_action :require_is_user

  def index
    @album = Collection.find(collection_name).albums.detect do |album|
      album.name == params[:album_name]
    end
    @photos = album.photos.small
  end

  private

  def collection_name
    params[:collection_name]
  end

end
