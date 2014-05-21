class CreateShopPictures < ActiveRecord::Migration
  def change
    create_table :shop_pictures do |t|
      t.references :product, index: true
      t.string :path
      t.text :description

      t.timestamps
    end
  end
end
