class Collection
  BASE_DIR = Rails.application.secrets.base_photo_path

  attr_reader :name, :base_album_paths

  def self.find(collection_name)
    new(collection_name)
  end

  def self.reset
    @@collections = nil
  end

  def initialize(name)
    @name        = name
    @base_album_paths = Collection.base_album_paths(name)
  end

  def albums
    @albums ||= base_album_paths.map do |outer_album_path|
      Album.album_paths(outer_album_path).map do |album_path|
        Album.new(self, album_path)
      end
    end.flatten.sort_by(&:name)
  end

  def self.names
    base_album_infos.keys
  end

  def self.basepath
    Rails.application.secrets.base_photo_path
  end

  private

  def self.base_album_infos
    @@collections ||=
      Dir.entries(basepath).select do |name|
        match_collection(name)
      end.map do |collection_path|
        {
          collection_name: extracted_collection_name(collection_path),
          path:            File.join(basepath, collection_path),
          name:            collection_path
        }
      end.group_by do |collection_info|
        collection_info[:collection_name]
      end
  end

  def self.base_album_paths(collection_name)
    base_album_infos[collection_name].map do |collection_info|
      collection_info[:path]
    end
  end

  def self.extracted_collection_name(collection_path)
    match_collection(File.basename(collection_path))
  end

  def self.match_collection(collection_string)
    return nil if collection_string.index(".")
    collection_containing_year =
      /\d{4}/.match(File.basename(collection_string)) do |m|
        m[0]
      end
    return collection_containing_year if collection_containing_year
    collection_string
  end

end
