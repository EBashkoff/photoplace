class PhotosController < ApplicationController

  attr_reader :photos
  helper_method :photos

  def index
    @photos = Collection.all.last(2).first.albums.last.photos.large
    puts photos.map(&:title)
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
