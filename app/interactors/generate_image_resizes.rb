class GenerateImageResizes
  include Magick

  attr_reader :image_path

  def initialize(image_path)
    # Image path is path of full size image
    @image_path = image_path
  end

  def run
    return false unless allowed?

    image = Image.read(image_path).first
    thumb_image = image.resize_to_fill(100)
    thumb_image.write(target_paths(image_path)[:thumb])

    if image.columns > image.rows
      small_image = image.resize_to_fill(320, 240)
      medium_image = image.resize_to_fill(800, 600)
      large_image = image.resize_to_fill(1024, 768)
    else
      small_image = image.resize_to_fill(240, 320)
      medium_image = image.resize_to_fill(600, 800)
      large_image = image.resize_to_fill(768, 1024)
    end
    small_image.write(target_paths(image_path)[:small])
    medium_image.write(target_paths(image_path)[:medium])
    large_image.write(target_paths(image_path)[:large])

  end

  private

  def allowed?
    return false unless image_path.present?
    return false unless (path_parts = image_path.split("/")).length > 3
    return false unless path_parts[-2] == "full"
    true
  end

  def target_paths(full_image_path)
    {
      thumb: full_image_path.sub("/full/", "/thumb/"),
      small: full_image_path.sub("/full/", "/small/"),
      medium: full_image_path.sub("/full/", "/medium/"),
      large: full_image_path.sub("/full/", "/large/")
    }
  end

end


