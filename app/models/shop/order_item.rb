class Shop::OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :product_sku

  belongs_to :delivery

  def price_yuan
      format("%.2f",self.price.to_i / 100.00)    
  end
end
