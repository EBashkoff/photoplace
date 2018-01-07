class Album < ApplicationRecord

  validates :title, presence: true
  validates :description, presence: true
  validates :path, presence: true

  belongs_to :collection
  has_many :photos

end
