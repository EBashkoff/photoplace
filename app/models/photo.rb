require 'exifr/jpeg'

class Photo < ApplicationRecord

  belongs_to :album

  before_save :put_exif_in_new_record
  before_save :save_path_info

  mount_uploader :image, ImageUploader

  def filename
    image.file.filename
  end

  def filetype
    filename.split(".").last.downcase
  end

  def set_path
    self.path = File.join(album.collection.name, album.path, filename)
  end

  private

  def put_exif_in_new_record
    save_exif_info if new_record?
  end

  def save_exif_info
    if image
      self.latitude = exifr.gps_latitude.to_f * latitude_sign
      self.longitude = exifr.gps_longitude.to_f * longitude_sign
      self.height = exifr.height
      self.width = exifr.width
      self.description = exifr.image_description
      app13 = exifr.app1s[1]
      self.title =
        if app13
          html_doc = Nokogiri::HTML(app13)
          html_doc.css('title').xpath('alt/li').text
        end
      self.orientation =
        if width && height
          width > height ? "landscape" : "portrait"
        end
    end
  end

  def save_path_info
    if new_record? && image
      set_path
    end
  end

  def exifr
    @exifr ||=
      begin
        EXIFR::JPEG.new(StringIO.new(image.file.read))
      end
  end

  def longitude_sign
    exifr.gps_longitude_ref == 'E' ? 1.0 : -1.0
  end

  def latitude_sign
    exifr.gps_latitude_ref == 'N' ? 1.0 : -1.0
  end

end
