class Shop::OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product_sku
end
