class GoogleManifestController < ApplicationController

  def index
    manifest = JSON.parse(IO.read("db/manifest.json"))
    manifest["start_url"] = collections_path
    manifest["icons"].each do |icon|
      icon["src"] = ActionController::Base.helpers.image_path(icon["src"])
    end

    render json: manifest
  end

end
