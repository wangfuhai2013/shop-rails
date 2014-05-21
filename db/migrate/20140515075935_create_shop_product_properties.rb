class CreateShopProductProperties < ActiveRecord::Migration
  def change
    create_table :shop_product_properties do |t|
      t.references :product, index: true
      t.references :property, index: true
      t.references :property_value, index: true
      t.string :input_value

      t.timestamps
    end
  end
end
