class CreateShopProductSkuProperties < ActiveRecord::Migration
  def change
    create_table :shop_product_sku_properties do |t|
      t.references :product_sku, index: true
      t.references :property, index: true
      t.references :property_value, index: true

      t.timestamps
    end
  end
end
