class CreateShopOrderItems < ActiveRecord::Migration
  def change
    create_table :shop_order_items do |t|
      t.references :order, index: true
      t.references :product_sku, index: true
      t.integer :quantity
      t.integer :price
      t.integer :discount

      t.timestamps
    end
  end
end
