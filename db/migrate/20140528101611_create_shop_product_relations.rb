class CreateShopProductRelations < ActiveRecord::Migration
  def change
    create_table :shop_product_relations do |t|
       t.references :product, index: true
       t.integer :relation_product_id
       t.integer :the_order
    end
  end
end
