class CollectionsController < ApplicationController

  attr_reader :collections
  helper_method :collections

  before_action :require_is_user

  def index
    @collections = Collection.order(:name).includes(:albums).all
  end

end
