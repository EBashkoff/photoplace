require "FileUtils"

class UploadsController < ApplicationController

  MAX_UPLOAD_SIZE = 12 * 1000 * 1000

  before_action :require_is_admin

  attr_reader :album_paths
  helper_method :album_paths

  def index
    unless is_valid_base_path? && base_folder_exists?
      render json: { statusText: "Invalid image root directory given" },
             status: :not_found
      return
    end

    full_photos_meta = Collection.names.map do |collection_name|
      Collection.find(collection_name).albums
    end.flatten.detect do |album|
      album.album_path == URI.decode(params["newFolder"])
    end.photos.full.map do |photo|
      { filename: photo.filename, path: photo.path }
    end

    render json: full_photos_meta
  end

  def new
    Collection.reset
    paths = Collection.names.map do |collection_name|
      Collection.find(collection_name).albums
    end.flatten.map(&:path)

    @album_paths = paths.map do |path|
      [stripped_photo_path(path), path]
    end

    gon.create_folders_url = uploads_create_folders_url
    gon.upload_file_url    = uploads_upload_file_url
    gon.full_res_files_url = uploads_full_res_files_url
    gon.resize_file_url    = uploads_resize_file_url
    gon.max_upload_size    = MAX_UPLOAD_SIZE
    gon.base_photo_path    = Rails.application.secrets.base_photo_path
  end

  def create
    unless is_valid_base_path?
      render json: { statusText: "Invalid image root directory given" },
             status: :not_acceptable
      return
    end

    Photo::RESOLUTIONS.each do |resolution|
      FileUtils.mkdir_p "#{params["newFolder"]}/images/#{resolution.to_s}"
    end

    render json: { created_folder_root: params["newFolder"] }

  rescue
    render json: { statusText: "Could not create directories on server" },
           status: :internal_server_error
  end

  def upload_file
    unless is_valid_base_path? && base_folder_exists?
      render json: { statusText: "Invalid image root directory given" },
             status: :not_acceptable
      return
    end

    pre_existing_file = File.exists?(photo_file_path)
    IO.write(photo_file_path, params[:file])
    render json: { success: true, overwritten: pre_existing_file, filename: params["filename"] }

  rescue => e
    render json: { statusText: "Could not create file on server", success: false },
           status: :internal_server_error
  end

  def resize_file
    unless is_valid_base_path? && base_folder_exists?
      render json: { statusText: "Invalid image root directory given" },
             status: :not_found
      return
    end

    job = GenerateImageResizes.new(photo_file_path)
    job.run
    render json: { sourcefile: photo_file_path, results: job.result }
  end

  private

  def stripped_photo_path(album_path)
    album_path.sub("#{Rails.application.secrets.base_photo_path}/", "")
  end

  def is_valid_base_path?
    params["newFolder"].start_with?(Rails.application.secrets.base_photo_path)
  end

  def base_folder_exists?
    File.exists?(params["newFolder"])
  end

  def photo_file_path
    File.join(params["newFolder"], params["filename"])
  end

end
