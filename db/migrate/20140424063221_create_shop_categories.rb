class CreateShopCategories < ActiveRecord::Migration
  def change
    create_table :shop_categories do |t|
      t.string :name
      t.references :account, index: true
      t.string :code
      t.integer :the_order      
      t.string :picture_path
      t.boolean :is_enabled

      t.timestamps
    end
  end
end
