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

	def photo_meta
		return @photo_meta if @photo_meta
		meta =
			album
				.album_meta[:photos]
				.detect { |photo| photo.keys.first.to_s == filename }
				.values
				.first
		@photo_meta = OpenStruct.new(meta)
	end

	def title(from_exif: false)
		return photo_meta.title unless from_exif
		app13 = exifr.app1s[1]
		return "" unless app13
    html_doc = Nokogiri::HTML(app13)
		html_doc.css('title').xpath('alt/li').text
	end

	def description(from_exif: false)
		return photo_meta.description unless from_exif
		exifr&.exif&.image_description || ""
	end

	def longitude(from_exif: false)
		return photo_meta.longitude unless from_exif
		exifr.gps&.longitude
	end

	def latitude(from_exif: false)
		return photo_meta.latitude unless from_exif
		exifr.gps&.latitude
	end

	def width(from_exif: false)
		return photo_meta.width unless from_exif
		exifr&.width
	end

	def height(from_exif: false)
		return photo_meta.height unless from_exif
		exifr&.height
	end

	def orientation(from_exif: false)
		return photo_meta.orientation unless from_exif
		o_width = width(from_exif: from_exif)
		o_height = height(from_exif: from_exif)
		return "" unless o_width && o_height
		o_width > o_height ? "landscape" : "portrait"
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
