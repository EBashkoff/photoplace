class AddPathToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :path, :string
  end
end
