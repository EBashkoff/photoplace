class Album

  attr_reader :collection
  attr_accessor :album_path, :album_name, :album_tooltip

  def initialize(collection, album_path)
    @collection = collection
    @album_path = album_path
  end

  def path
    album_path
  end

  def name
    @name ||= File.basename(album_path)
  end

  def app_path
    album_path.gsub(Rails.application.secrets.base_photo_path, "photos")
  end

  def photos
    @photos ||=
      Photo::RESOLUTIONS.reduce({}) do |m, resolution|
        photo_objects = Photo.photo_paths(album_path)
                          .send(resolution)
                          .map do |photo_path|
          Photo.new(self, photo_path)
        end
        m.merge({resolution => photo_objects})
      end.extend(Photo::Resolutions)
  end

	def title
    @album_title ||= album_xml.xpath("//groupTitle").first.try(:content)
  end

	def description
    @album_description ||= album_xml.xpath("//groupDescription").first.try(:content)
  end

  def self.album_paths(collection_path)
    [recurse_album_paths(collection_path)].flatten
  end

  def self.recurse_album_paths(directory)
    paths = Dir[File.join(directory, "*")].select do |path|
      File.directory?(path)
    end
    paths.map do |path|
      return path.gsub("/images", "") if paths && paths.map { |path| File.basename(path) }.include?("images")
      recurse_album_paths(path)
    end
  end

	private

	def resource_path
    @resource_path ||= File.join(path, "/resources/mediaGroupData/group.xml")
  end

	def album_xml
    @album_xml ||= Nokogiri::XML(IO.read(resource_path))
  end

end
