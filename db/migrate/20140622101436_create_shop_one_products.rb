class CreateShopOneProducts < ActiveRecord::Migration
  def change
    create_table :shop_one_products do |t|
      t.references :account, index: true
      t.references :product, index: true
      t.integer :issue_no
      t.integer :price
      t.integer :join_person_time
      t.integer :result_code
      t.references :result_customer, index: true
      t.datetime :result_time
      t.boolean :is_closed

      t.string :receiver_name
      t.string :receiver_mobile     
      t.references :receiver_province
      t.references :receiver_city
      t.references :receiver_area
      t.string :receiver_address      
      t.string :receiver_zip        
      t.boolean :receiver_is_confirmed

      t.references :logistic, index: true
      t.string :express_no
      t.boolean :is_delivered
      t.datetime :delivery_date
      t.text :remark

      t.timestamps
    end
  end
end
