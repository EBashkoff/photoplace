class GenerateImageResizes
  include Magick

  attr_reader :image_path, :image, :result

  DIMENSIONS = {
    thumb:  [100],
    small:  {
      landscape: [320, 240],
      portrait:  [240, 320]
    },
    medium: {
      landscape: [800, 600],
      portrait:  [600, 800]
    },
    large:  {
      landscape: [1024, 768],
      portrait:  [768, 1024]
    }
  }.freeze

  def initialize(image_path)
    # Image path is path of full size image
    @image_path = image_path
  end

  def run
    return false unless allowed?

    @image = Image.read(image_path).first

    @result = (Photo::RESOLUTIONS - [:full]).reduce({}) do |m, resolution|
      destination_filename = target_paths(image_path)[resolution]
      result               = {
        overwritten: File.exists?(destination_filename),
        path:        destination_filename
      }

      begin
        resized_image = image.resize_to_fill(*dimensions(resolution))
        resized_image.write(destination_filename)
        result[:success] = true
      rescue => e
        Rails.logger.error("IN #{self.class}: #{e.message}")
        result[:success] = false
      end

      m.merge({ resolution => result })
    end
    true
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
      thumb:  full_image_path.sub("/full/", "/thumb/"),
      small:  full_image_path.sub("/full/", "/small/"),
      medium: full_image_path.sub("/full/", "/medium/"),
      large:  full_image_path.sub("/full/", "/large/")
    }
  end

  def dimensions(resolution)
    if resolution == :thumb
      DIMENSIONS[resolution]
    else
      orientation = (image.columns > image.rows) ? :landscape : :portrait
      DIMENSIONS[resolution][orientation]
    end
  end

end


