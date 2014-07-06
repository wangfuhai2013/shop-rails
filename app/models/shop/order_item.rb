class Shop::OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product_sku

  belongs_to :delivery
end
