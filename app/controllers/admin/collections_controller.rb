module Admin
  class CollectionsController < ApplicationController

    attr_reader :collection

    before_action :require_is_admin

    attr_reader :collections, :collection
    helper_method :collections, :collection

    def index
      @collections = collections.page(params[:page]).per(12)
    end

    def show
      collection
    end

    def new
      collection
    end

    def create
      if collection.update(collection_params)
        flash.now[:success] = 'The collection was successfully created.'
        render :show
      else
        flash.now[:error] = ['The collection could not be successfully created.']
        render :new
      end
    end

    def edit
      collection
    end

    def update
      if collection.update(collection_params)
        flash.now[:success] = 'The collection was successfully updated.'
        render :show
      else
        flash.now[:error] = ['The collection could not be successfully updated.']
        render :edit
      end
    end

    private

    def collections
      @collections ||=
        Collection
          .left_joins(:albums)
          .select("collections.name AS name, collections.id AS id, " \
                  "count(albums.id) AS album_count, collections.created_at AS created_at")
          .group(:id)
          .order(:name)
    end

    def collection
      @collection ||= Collection.find_or_initialize_by(id: params[:id]) do |collection|
        collection.order_index = Collection.count + 1
      end
    end

    def collection_params
      params.require(:collection).permit(:name, :id)
    end

  end
end
