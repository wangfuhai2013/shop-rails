class CreateShopProductSkus < ActiveRecord::Migration
  def change
    create_table :shop_product_skus do |t|
      t.references :product, index: true
      t.string :code
      t.integer :price
      t.integer :quantity
      t.boolean :is_enaled

      t.timestamps
    end
  end
end
