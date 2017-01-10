require 'zip'

class DownloadsController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album, :collection_name

  before_action :require_is_user

  def index
    @album = Collection.find(collection_name).albums.detect do |album|
      album.name == params[:album_name]
    end

    respond_to do |format|
      format.html do
        @photos = album.photos.small.sort_by(&:filename)
      end

      format.zip do |variant|
        unless resolution.present? && photo_names.present?
          variant.none
          redirect_to downloads_path
          return
        end
        variant.any do
          if photo_names.count > 1
            send_zipfile
          else
            send_single_image
          end
        end
      end
    end
  end

  private

  def send_zipfile
    stream = Zip::OutputStream::write_buffer do |zip|
      photo_names.each do |_, filename|
        zip.put_next_entry(filename)
        zip.write(selected_photo_content(filename))
      end
    end

    stream.rewind
    zipbody = stream.sysread
    headers["Content-Type"] = "application/json"
    send_data(
      zipbody,
      filename:    "#{album.name}.zip",
      disposition: :attachment
    )
  end

  def send_single_image
    filename = photo_names.values.first
    send_data(
      selected_photo_content(filename),
      filename:    filename,
      disposition: :attachment
    )
  end

  def collection_name
    params[:collection_name]
  end

  def photo_names
    params[:photo_names]
  end

  def resolution
    params[:resolution]
  end

  def selected_photo_content(filename)
    target_photo = album.photos.send(resolution).detect do |photo|
      photo.filename == filename
    end
    return "" unless target_photo
    S3Wrapper.get(target_photo.path)
  end

end
