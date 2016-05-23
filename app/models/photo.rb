require 'exifr'

class Photo
	BASE_DIR = Rails.application.secrets.base_photo_path

  # Permissible collection names are these plus any those having a name with a
  # 4 digit number
	PERMISSIBLE_COLLECTION_NAMES =
		[
			"house", "scanned photo albums"
		]

	RESOLUTIONS = [:full, :large, :medium, :small, :thumb]

	attr_reader :photos, :album
	attr_accessor :photo_path

	def initialize(album, photo_path)
		@album      = album
		@photo_path = photo_path
	end

	def path
		photo_path
	end

	def filename
		File.basename(photo_path)
  end

  def filetype
    File.extname(photo_path).sub(/^\./, "")
  end

	def app_path
    photo_path.gsub(Rails.application.secrets.base_photo_path, "photos")
	end

	def title
		app13 = exifr.app1s[1]
		return "" unless app13
    html_doc = Nokogiri::HTML(app13)
		html_doc.css('title').xpath('alt/li').text
	end

	def description
		exifr.exif.image_description
	end

	def longitude
		exifr.gps.try(:longitude)
	end

	def latitude
		exifr.gps.try(:latitude)
	end

	def width
		exifr.try(:width)
	end

	def height
		exifr.try(:height)
	end

	def orientation
		width > height ? "landscape" : "portrait"
	end

	def size
		File.size(photo_path)
	end

	def self.photo_paths(album_path)
		RESOLUTIONS.reduce({}) do |m, resolution|
			m.merge({ resolution => Dir[File.join(album_path, "images", resolution.to_s, "*.jpg")] })
		end.extend(Resolutions)
	end

	module Resolutions
		def objects
			self
		end

		def full
      self[:full]
		end

		def large
      self[:large]
		end

		def medium
      self[:medium]
		end

		def small
      self[:small]
		end

		def thumb
      self[:thumb]
		end
	end

	private

	def exifr
		# Always get EXIF data from the full resolution image
		@exifr ||= EXIFR::JPEG.new(self.photo_path.gsub(/\/(large|medium|small|thumb)\//, "/full/"))
	end

end
