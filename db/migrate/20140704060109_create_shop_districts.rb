class CreateShopDistricts < ActiveRecord::Migration
  def change
    create_table :shop_districts do |t|
      t.string :name
      t.integer :level
      t.integer :parent_id, index: true

      t.timestamps
    end
  end
end
