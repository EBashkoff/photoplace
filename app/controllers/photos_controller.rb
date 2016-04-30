
class PhotosController < ApplicationController
  attr_reader :photos
  helper_method :photos

  def index
    @photos = Collection.all.last.albums.last.photos.large.map { |photo| photo.path }
    render :index
  end
end