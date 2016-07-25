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
        m.merge({ resolution => photo_objects })
      end.extend(Photo::Resolutions)
  end

  def title
    album_xml.xpath("//groupTitle").first.try(:content)
  end

  def description
    album_xml.xpath("//groupDescription").first.try(:content)
  end

  def self.album_paths(collection_path)
    recurse_album_paths(collection_path)
  end

  def self.recurse_album_paths(directory, m = [])
    Dir[File.join(directory, "*")].select do |path|
      File.directory?(path) && !path.end_with?("/resources")
    end.each do |path|
      if File.basename(path) == "images"
        m << path.gsub("/images", "")
      else
        recurse_album_paths(path, m)
      end
    end
    m
  end

  def photo_index(filename)
    Photo.photo_paths(self.path).large.each_with_index.detect do |one_pic_path, index|
      one_pic_path.end_with?(filename)
    end.last
  end

  def update_xml(title:, description:)
    self.description = description
    self.title       = title
    IO.write(resource_path, album_xml)
    @album_xml = nil
    album_xml
  end

  private

  def resource_path
    @resource_path ||= File.join(path, "/resources/mediaGroupData/group.xml")
  end

  def album_xml
    @album_xml ||=
      begin
        unless File.exists?(resource_path)
          xml = IO.read(File.join(Rails.root, "db", "xml_resource_template.xml"))
          FileUtils.mkdir_p File.dirname(resource_path)
          IO.write(resource_path, xml)
        end
        Nokogiri::XML(IO.read(resource_path))
      end
  end

  def title=(content)
    album_xml.xpath("//groupTitle").first.content = content
  end

  def description=(content)
    album_xml.xpath("//groupDescription").first.content = content
  end

end
