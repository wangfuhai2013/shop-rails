module Shop
  class DeliveryItem < ActiveRecord::Base
    belongs_to :delivery
    belongs_to :product
    belongs_to :product_sku
  end
end
