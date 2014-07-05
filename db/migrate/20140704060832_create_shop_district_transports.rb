class CreateShopDistrictTransports < ActiveRecord::Migration
  def change
    create_table :shop_district_transports do |t|
      t.references :account, index: true
      t.references :district, index: true
      t.integer :price

      t.timestamps
    end
  end
end
