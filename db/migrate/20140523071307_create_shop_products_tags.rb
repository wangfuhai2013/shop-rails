class CreateShopProductTags < ActiveRecord::Migration
  def change
    create_table :shop_product_tags do |t|
      t.references :product, index: true
      t.references :tag, index: true
    end
  end
end
