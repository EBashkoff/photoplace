class Collection
  BASE_DIR = Rails.application.secrets.base_photo_path
  PERMISSIBLE_COLLECTION_NAMES =
    [
      "house", "scanned photo albums"
    ]

  attr_accessor :collection_path, :collection_name

  def initialize
    Collection.collection_paths
    Collection.collection_names
  end

  def path
    collection_path
  end

  def name
    collection_name
  end

  def albums
    @albums ||=
      Album.album_paths(self.collection_path).map do |album_path|
        Album.new(self, album_path)
      end
  end

  def self.find(collection_name)
    collection = new
    collection.collection_name = collection_name
    collection.collection_path = collection_paths.detect do |path|
      path.end_with?(collection_name)
    end
    collection
  end

  def self.all
    collection_names.map do |collection_name|
      find(collection_name)
    end
  end

  def self.collection_names
    @@collection_names ||=
      Dir.entries(basepath).select do |name|
        PERMISSIBLE_COLLECTION_NAMES.include?(name.downcase) || /\d{4}/.match(name)
      end
  end

  def self.collection_paths
    @@collection_paths ||=
      collection_names.map do |path|
        File.join(basepath, path)
      end
  end

  def self.basepath
    Rails.application.secrets.base_photo_path
  end

end
