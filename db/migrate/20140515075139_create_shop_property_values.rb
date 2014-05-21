class CreateShopPropertyValues < ActiveRecord::Migration
  def change
    create_table :shop_property_values do |t|
      t.references :property, index: true
      t.string :code
      t.string :value
      t.integer :the_order
      t.boolean :is_enabled

      t.timestamps
    end
  end
end
