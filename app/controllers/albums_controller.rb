require 'zip'

class AlbumsController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album, :collection_name

  before_action :require_is_admin

  attr_reader :albums, :album
  helper_method :albums, :album

  def index
    albums
  end

  def show
    album
  end

  def edit
    album
  end

  def update
    album.update_meta(album_params)
    render :show
  end

  private

  def albums
    @albums ||= Collection.names.map do |collection_name|
      Collection.find(collection_name).albums
    end.flatten.sort_by(&:path)
  end

  def album
    @album ||= Album.find_by_id(params[:id])
  end

  def album_params
    params.permit(:title, :description).symbolize_keys
  end

end
