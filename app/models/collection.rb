class Collection < ApplicationRecord

  PERMISSIBLE_COLLECTION_NAMES =
    [
      "house", "others", "Albums 1-4", "Albums 5-8"
    ]

  has_many :albums

  validates :name, presence: true, uniqueness: true

  def self.match_collection(collection_string)
    /(\d{4}|#{PERMISSIBLE_COLLECTION_NAMES.join("|")})/i
      .match(File.basename(collection_string)) do |m|
      m[1]
    end
  end

end
