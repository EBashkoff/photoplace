class Album < ApplicationRecord

  validates :title, presence: true
  validates :description, presence: true
  validates :path, presence: true, uniqueness: true

  belongs_to :collection
  has_many :photos

  def add_photo_order_indexes
    index = photos.where.not(order_index: nil).count
    photos.where(order_index: nil).order(:created_at).each do |photo|
      index += 1
      photo.update(order_index: index)
    end
  end

end
