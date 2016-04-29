
class PhotosController < ApplicationController
  attr_reader :photos
  helper_method :photos

  def index
    @photos = Photo.all.map {|photo| File.new(photo)}
    render :index
  end
end