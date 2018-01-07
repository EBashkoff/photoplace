class CreateAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.string :path
      t.string :title
      t.string :description
      t.integer :order_index
      t.references :collection, foreign_key: true

      t.timestamps
    end
  end
end
