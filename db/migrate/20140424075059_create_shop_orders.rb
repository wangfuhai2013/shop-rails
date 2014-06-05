class CreateShopOrders < ActiveRecord::Migration
  def change
    create_table :shop_orders do |t|
      t.references :account, index: true
      t.references :customer, index: true      
      t.string :order_no
      t.string :pay_way
      t.integer :total_fee
      t.integer :product_fee
      t.integer :transport_fee
      t.boolean :is_paid
      t.boolean :is_delivered
      t.datetime :paid_date
      t.datetime :delivery_date
      t.text :delivery_address
      t.text :remark
      t.string :openid

      t.timestamps
    end
  end
end
