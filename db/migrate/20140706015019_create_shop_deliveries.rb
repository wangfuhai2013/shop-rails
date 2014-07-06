class CreateShopDeliveries < ActiveRecord::Migration
  def change
    create_table :shop_deliveries do |t|
      t.references :order, index: true
      t.references :logistic, index: true
      t.string :invoice_no
      t.text :remark

      t.timestamps
    end
  end
end
