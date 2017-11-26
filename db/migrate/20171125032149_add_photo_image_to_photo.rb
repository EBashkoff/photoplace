class AddPhotoImageToPhoto < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.integer :height
      t.integer :width
      t.float :latitude
      t.float :longitude
      t.string :photo_image
    end
  end
end
