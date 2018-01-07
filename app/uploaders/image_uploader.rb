class ImageUploader < CarrierWave::Uploader::Base

  # attr_accessor :height, :width

  # before :cache, :store_dimensions

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog
  storage :aws

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    Rails.application.secrets.aws_s3_base_dir + '/' + model.path
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # def portrait?
  #   if
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  version :small do
    process resize_to_fit: [320, 240]
  end

  version :medium do
  end
  process resize_to_fit: [800, 600]

  version :large do
  end
  process resize_to_fit: [1024, 768]

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg)
  end

  # def store_dimensions(file)
    # puts "STORE DIMENSIONS PARAM TEST #{test.class} : #{test}"
    # if file && model
    #   width, height = ::MiniMagick::Image.open(file.file)[:dimensions]
    #   puts "STORE DIMENSIONS WIDTH #{width} HEIGHT #{height}"
    #   model.width, model.height = [width, height]
    # end
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
