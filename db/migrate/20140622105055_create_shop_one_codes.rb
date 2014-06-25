class CreateShopOneCodes < ActiveRecord::Migration
  def change
    create_table :shop_one_codes do |t|
      t.references :one_product, index: true
      t.references :customer, index: true
      t.references :one_order, index: true
      t.integer :code

      t.timestamps
    end
  end
end
