class CreateShopLogistics < ActiveRecord::Migration
  def change
    create_table :shop_logistics do |t|
      t.references :account, index: true
      t.string :name

      t.timestamps
    end
  end
end
