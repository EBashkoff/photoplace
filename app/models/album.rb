class Album

  attr_reader :collection_name
  attr_accessor :album_path, :album_name, :album_tooltip

  def initialize(collection_name, album_path)
    @collection_name = collection_name
    @album_path      = album_path
    album_meta
  end

  def path
    album_path
  end

  def name
    @name ||= File.basename(album_path)
  end

  def photos
    @photos ||=
      Photo::RESOLUTIONS.reduce({}) do |m, resolution|
        photo_objects = Photo.photo_paths(self)
                          .send(resolution)
                          .map do |photo_path|
          Photo.new(self, photo_path)
        end
        m.merge({ resolution => photo_objects })
      end.extend(Photo::Resolutions)
  end

  def title
    (album_meta || { title: "NO TITLE" })[:title]
  end

  def description
    (album_meta || { description: "NO DESCRIPTION" })[:description]
  end

  def photo_filenames
    album_meta[:photo_filenames].sort
  end

  def photo_index(filename)
    photo_filenames
      .each_with_index
      .detect { |one_pic_path, index| one_pic_path.end_with?(filename) }
      .last
  end

  def update_meta(title:, description:)
    album_meta[:description] = description
    album_meta[:title]       = title
    S3Wrapper.put(resource_path, album_meta)
    album_meta
  end

  private

  def resource_path
    @resource_path ||= File.join(path, "resource.json")
  end

  def album_meta
    @album_meta ||= S3Wrapper.get(resource_path)
  end

end
