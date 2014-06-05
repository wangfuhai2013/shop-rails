class CreateShopCustomerTypes < ActiveRecord::Migration
  def change
    create_table :shop_customer_types do |t|
      t.string :name
      t.integer :discount
      t.text :remark
      t.references :account, index: true     

      t.timestamps
    end
  end
end
