class CreateShopOneOrders < ActiveRecord::Migration
  def change
    create_table :shop_one_orders do |t|
      t.references :account, index: true
      t.references :one_product, index: true
      t.references :customer, index: true
      t.integer :order_person_time
      t.string :pay_way
      t.datetime :pay_time
      t.boolean :is_paid
      t.string :trade_no
      t.integer :got_code_quantity
      t.boolean :is_got_all_code

      t.timestamps
    end
  end
end
