class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.string :title
      t.string :description
      t.float :longitude
      t.float :latitude
      t.integer :height
      t.integer :width
      t.string :orientation
      t.string :image
      t.integer :order_index
      t.references :album, foreign_key: true

      t.timestamps
    end
  end
end
