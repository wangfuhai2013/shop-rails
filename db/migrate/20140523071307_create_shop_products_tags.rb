class CreateShopProductsTags < ActiveRecord::Migration
  def change
    create_table :shop_products_tags do |t|
      t.references :product, index: true
      t.references :tag, index: true
    end
  end
end
