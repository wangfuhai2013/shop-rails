class CreateShopProperties < ActiveRecord::Migration
  def change
    create_table :shop_properties do |t|
      t.string :name
      t.string :code
      t.references :account, index: true            
      t.references :category, index: true
      t.string :data_type
      t.boolean :is_multiple
      t.boolean :is_required
      t.boolean :is_sku
      t.integer :the_order
      t.boolean :is_enabled

      t.timestamps
    end
  end
end
