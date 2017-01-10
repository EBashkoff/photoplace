class Collection
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
    @albums ||= base_album_paths.map do |album_path|
      Album.new(self.name, album_path)
    end.flatten.sort_by(&:name)
  end

  def self.names
    base_album_infos.keys.map(&:to_s).sort
  end

  private

  def self.base_album_infos
    @@collections ||= S3Wrapper.get("resource.json")
  end

  def self.base_album_paths(collection_name)
    base_album_infos[collection_name.to_sym]
  end

end
