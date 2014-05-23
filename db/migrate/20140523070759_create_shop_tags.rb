class CreateShopTags < ActiveRecord::Migration
  def change
    create_table :shop_tags do |t|
      t.string :name
      t.references :account, index: true      
      t.integer :the_order
      t.boolean :is_enabled
      
      t.timestamps
    end
  end
end
