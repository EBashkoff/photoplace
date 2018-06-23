require 'zip'

class DownloadsController < ApplicationController

  attr_reader :photos, :album
  helper_method :photos, :album

  before_action :require_is_user

  def index
    respond_to do |format|
      format.html do
        @photos = album.photos.sort_by(&:order_index)
      end

      format.zip do |variant|
        unless resolution.present? && photo_ids.present?
          variant.none
          redirect_to downloads_path
          return
        end
        variant.any do
          if photo_ids.count > 1
            send_zipfile
          else
            send_single_image
          end
        end
      end
    end
  end

  private

  def album
    @album ||= Album.find_by(id: params[:album_id])
  end

  def send_zipfile
    stream = Zip::OutputStream::write_buffer do |zip|
      selected_photos.each do |photo|
        zip.put_next_entry(photo.filename)
        zip.write(photo.image.read)
      end
    end

    stream.rewind
    zipbody                 = stream.sysread
    headers["Content-Type"] = "application/json"
    send_data(
      zipbody,
      filename:    "#{album.title}.zip",
      disposition: :attachment
    )
  end

  def send_single_image
    photo = selected_photos.first
    send_data(
      photo.image.read,
      filename:    photo.filename,
      disposition: :attachment
    )
  end

  def photo_ids
    download_params[:photo_ids].split(',')
  end

  def resolution
    download_params[:resolution]
  end

  def selected_photos
    @selected_photos ||= Photo.where(id: photo_ids)
  end

  def download_params
    params.permit :album_id, :resolution, :photo_ids, :_method,
                  :authenticity_token, :format
  end

end
