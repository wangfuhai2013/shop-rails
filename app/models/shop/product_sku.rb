module Shop
  class ProductSku < ActiveRecord::Base
    belongs_to :product

    validates_presence_of :product
    validates :price, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
    validates :quantity, numericality: { only_integer: true ,greater_than_or_equal_to: 0}  
    validates_uniqueness_of :code

    has_many :product_sku_properties

    def product_sku_property_list
       list = ""
       self.product_sku_properties.each do |product_sku_property|
         list += product_sku_property.property.name + ":" + product_sku_property.property_value.value + ";"
       end
       list
    end
  end
end
