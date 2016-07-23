require "fileutils"

class CreateResizeFolders

  attr_reader :album_path

  def initialize(album_path)
    # Ensures we get the base path of the album regardless of whether we are
    # given db/<album name>/images/full or db/<album name>/images
    @album_path = album_path.gsub("/full", "").gsub("/images", "")
  end

  def run
    return false unless allowed?

    target_paths_present.each do |resolution, present|
      unless present
        FileUtils.mkdir_p File.join(album_path, "images", resolution.to_s)
      end
    end
    true
  rescue => e
    Rails.logger.error("IN #{self.class}: #{e.message}")
    false
  end

  private

  def allowed?
    return false unless album_path.present?
    true
  end

  def target_paths_present
    {
      thumb:  File.exist?(File.join(album_path, "images", "thumb")),
      small:  File.exist?(File.join(album_path, "images", "small")),
      medium: File.exist?(File.join(album_path, "images", "medium")),
      large:  File.exist?(File.join(album_path, "images", "large"))
    }
  end

end


