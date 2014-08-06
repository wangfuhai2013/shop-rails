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
      t.text :remark
      t.string :openid
      
      t.string :trade_no      
      t.integer :discount
      t.string :receiver_name
      t.string :receiver_mobile      
      t.string :receiver_address      
      t.string :receiver_zip       

      t.boolean :require_invoice
      t.string  :invoice_title   

      t.references :receiver_province
      t.references :receiver_city
      t.references :receiver_area

      t.integer :promotion_fee

      t.timestamps
    end
  end
end
