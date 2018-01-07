require 'exifr/jpeg'

class Photo < ApplicationRecord

  belongs_to :album

  before_save :save_exif_info
  before_save :save_path_info

  mount_uploader :image, ImageUploader

  def filename
    image.file.filename
  end

  def set_path
    self.path = File.join(album.collection.name, album.path, filename)
  end

  private

  def save_exif_info
    if new_record? && image
      self.latitude = exifr.gps_latitude
      self.longitude = exifr.gps_longitude
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

end
