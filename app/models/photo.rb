require 'exifr'

class Photo
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

	def cf_path(resolution = nil)
		target_path = path.dup
		target_path.sub!("/#{self.resolution}/", "/#{resolution}/") if resolution
		S3Wrapper.cloudfront_url(target_path.gsub(/\s+/, "+"))
	end

	def filename
		File.basename(photo_path)
  end

  def filetype
    File.extname(photo_path).sub(/^\./, "")
	end

	def resolution
		/\/(full|large|medium|small|thumb)\//.match(path) { |m| m[1] }
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

	def self.photo_paths(album)
		RESOLUTIONS.reduce({}) do |m, resolution|
			m.merge(
				{ resolution => album.photo_filenames.map do |filename|
					File.join(album.path, "images", resolution.to_s, filename)
				end }
			)
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
		@exifr ||=
			begin
				target_pic = S3Wrapper.get(path)
				EXIFR::JPEG.new(StringIO.new(target_pic))
			end
	end

end
