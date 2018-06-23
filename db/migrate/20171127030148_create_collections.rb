class CreateCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :collections do |t|
      t.string :name
      t.integer :order_index

      t.timestamps
    end
  end
end
