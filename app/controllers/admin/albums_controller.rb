require 'zip'

module Admin
  class AlbumsController < ApplicationController

    attr_reader :photos, :album
    helper_method :photos, :album, :collection_name

    before_action :require_is_admin

    attr_reader :albums, :album
    helper_method :albums, :album

    def index
      @albums = albums.page(params[:page]).per(12)
    end

    def show
      album
    end

    def edit
      album
    end

    def update
      if album.update(album_params)
        flash[:success] = 'The album was successfully updated.'
      else
        flash[:error] = ['The album could not be successfully updated.']
      end
      render :edit
    end

    private

    def albums
      @albums ||=
        Album
          .joins(:photos, :collection)
          .select("collections.name AS collection_name, albums.id AS id, " \
                  "collection_id, albums.title, albums.description, " \
                  "albums.path AS path, count(albums.id) AS photo_count")
          .group(:album_id)
          .order('collections.name, albums.path')
    end

    def album
      @album ||= albums.where("albums.id = ?", params[:id]).first
    end

    def album_params
      params.require(:album).permit(:title, :description, :id, :collection_id)
    end

  end
end
