class CollectionsController < ApplicationController

  attr_reader :collections
  helper_method :collections

  def index
    @collections = Collection.names.map do |collection_name|
      Collection.find(collection_name)
    end
  end

end
