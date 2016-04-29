require 'exifr'

class Photo
	BASE_DIR = Rails.application.secrets.base_photo_path
	PERMISSIBLE_COLLECTION_NAMES =
		[
			"house", "scanned photo albums"
		]
	RESOLUTIONS = %i(full large medium small thumb)

	attr_reader :photos, :album
	attr_accessor :photo_path

	def initialize(album, photo_path)
		@album      = album
		@photo_path = photo_path
	end

	def path
		photo_path
	end

	def title
		exifr.title
	end

	def caption
		exifr.caption
	end

	def longitude
		exifr.longitude
	end

	def latitude
		exifr.latitude
	end

	def self.photo_paths(album_path)
		RESOLUTIONS.reduce({}) do |m, resolution|
			m.merge({ resolution => Dir[File.join(album_path, "images", resolution.to_s, "*.jpg")] })
		end.extend(Resolutions)
	end

	module Resolutions
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
		@exifr ||= EXIFR::JPEG.new(self.photo_path)
	end

end
