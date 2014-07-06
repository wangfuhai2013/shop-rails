class CreateShopDeliveryItems < ActiveRecord::Migration
  def change
    create_table :shop_delivery_items do |t|
      t.references :delivery, index: true
      t.references :product_sku, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
