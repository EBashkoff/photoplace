class Album

  attr_reader :collection_name
  attr_accessor :album_path, :album_name, :album_tooltip

  RESOURCE_FILE = "resource.json"

  def self.find(collection_name, resource_path)
    new(collection_name, resource_path)
  end

  def self.find_by_id(id)
    album_path, target_album_info = @@albums_metadata.detect do |_, album_metadata|
      id == album_metadata[:id]
    end
    new(target_album_info[:collection_name], album_path.sub("/#{RESOURCE_FILE}", ""))
  end

  def initialize(collection_name, album_path)
    @collection_name = collection_name
    @album_path      = album_path
    album_meta
  end

  def id
    @id ||= Album.albums_meta(resource_path)[:id]
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
        photo_objects =
          Photo.photo_paths(self)
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
    album_meta[:photos].map { |photo| photo.keys.first.to_s }.sort if album_meta[:photos]
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

  def album_meta
    @album_meta ||= Album.albums_meta(resource_path)
  end

  def assemble_album_metadata
    photo_meta_array =
      photos
        .full
        .sort_by(&:filename)
        .map do |photo|
        {
          photo.filename => {
            title:       photo.title(from_exif: true),
            description: photo.description(from_exif: true),
            longitude:   photo.longitude(from_exif: true),
            latitude:    photo.latitude(from_exif: true),
            width:       photo.width(from_exif: true),
            height:      photo.height(from_exif: true),
            orientation: photo.orientation(from_exif: true)
          }
        }
      end

    resource_data = {
      id:              Album.hash_path(collection_name, resource_path),
      collection_name: collection_name,
      title:           self.title,
      description:     self.description,
      photos:          photo_meta_array
    }

    resource_s3_location = File.join(self.path, 'resource.json')
    S3Wrapper.put(resource_s3_location, resource_data)
  end

  private

  def resource_path
    @resource_path ||= File.join(path, RESOURCE_FILE)
  end

  def self.hash_path(collection_name, resource_path)
    digest = OpenSSL::Digest.new("md5")
    OpenSSL::HMAC.hexdigest(digest, collection_name, resource_path).slice(0, 10)
  end

  def self.albums_meta(resource_path)
    @@albums_metadata ||= {}

    return @@albums_metadata[resource_path] if @@albums_metadata[resource_path]

    @@albums_metadata[resource_path] = S3Wrapper.get(resource_path)
  end

end
