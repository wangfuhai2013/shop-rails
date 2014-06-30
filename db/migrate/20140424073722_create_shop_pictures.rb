class CreateShopPictures < ActiveRecord::Migration
  def change
    create_table :shop_pictures do |t|
      t.references :product, index: true
      t.references :product_sku_property, index: true
      t.string :path
      t.text :description

      t.timestamps
    end
  end
end
