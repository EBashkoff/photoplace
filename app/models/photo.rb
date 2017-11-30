require 'exifr/jpeg'

class Photo < ApplicationRecord

  belongs_to :album

  mount_uploader :image, ImageUploader

  private

  def exifr
    @exifr ||=
      begin
        EXIFR::JPEG.new(StringIO.new(image.file.read))
      end
  end

end
