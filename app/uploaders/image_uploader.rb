class ImageUploader < CarrierWave::Uploader::Base

  # attr_accessor :height, :width

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
    process resize_to_fit: [100, 100, combine_options: { 'auto_orient' => nil }]
  end

  version :small do
    process resize_to_fit: [320, 240, combine_options: { 'auto_orient' => nil }]
  end

  version :medium do
    process resize_to_fit: [800, 600, combine_options: { 'auto_orient' => nil }]
  end

  version :large do
    process resize_to_fit: [1024, 768, combine_options: { 'auto_orient' => nil }]
    process :store_dimensions
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg)
  end

  def store_dimensions
    puts "STORE DIMENSIONS PARAM TEST #{file.file}"
    if file && model
      width, height = ::MiniMagick::Image.open(file.file)[:dimensions]
      model.orientation = width > height ? 'landscape' : 'portrait'
      puts "STORE DIMENSIONS WIDTH #{width} HEIGHT #{height} ORIENTATION: #{model.orientation}"
    end
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
