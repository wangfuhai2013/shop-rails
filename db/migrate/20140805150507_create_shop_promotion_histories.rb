class CreateShopPromotionHistories < ActiveRecord::Migration
  def change
    create_table :shop_promotion_histories do |t|
      t.references :order, index: true
      t.references :customer, index: true
      t.string :change_type
      t.integer :change_points

      t.timestamps
    end
  end
end
