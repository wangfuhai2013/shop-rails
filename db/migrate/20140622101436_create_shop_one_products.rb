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

      t.timestamps
    end
  end
end
