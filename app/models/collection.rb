class Collection
  BASE_DIR                     = Rails.application.secrets.base_photo_path
  PERMISSIBLE_COLLECTION_NAMES =
    [
      "house", "others", "Albums 1-4", "Albums 5-8"
    ]

  attr_reader :name, :album_paths

  def self.find(collection_name)
    new(collection_name)
  end

  def initialize(name)
    @name        = name
    @album_paths = Collection.album_paths(name)
  end

  def albums
    @albums ||= album_paths.map do |outer_album_path|
      Album.album_paths(outer_album_path).map do |album_path|
        Album.new(self, album_path)
      end
    end.flatten
  end

  def self.names
    all.keys
  end

  def self.basepath
    Rails.application.secrets.base_photo_path
  end

  private

  def self.all
    @@collections ||=
      Dir.entries(basepath).select do |name|
        match_collection(name)
      end.map do |collection_path|
        {
          path: File.join(basepath, collection_path),
          name: extracted_collection_name(collection_path)
        }
      end.group_by do |collection_info|
        collection_info[:name]
      end
  end

  def self.album_paths(collection_name)
    all[collection_name].map do |collection_info|
      collection_info[:path]
    end
  end

  def self.extracted_collection_name(collection_path)
    match_collection(File.basename(collection_path))
  end

  def self.match_collection(collection_string)
    /(\d{4}|#{PERMISSIBLE_COLLECTION_NAMES.join("|")})/i
      .match(File.basename(collection_string)) do |m|
      m[1]
    end
  end

end
