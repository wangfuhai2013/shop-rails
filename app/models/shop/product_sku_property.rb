module Shop
  class ProductSkuProperty < ActiveRecord::Base
    belongs_to :product_sku
    belongs_to :property
    belongs_to :property_value

    validates_presence_of :product_sku,:property,:property_value
  end
end
