module Shop
  class ProductSku < ActiveRecord::Base
    belongs_to :product

    validates_presence_of :product,:code
    validates :price, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
    validates :quantity, numericality: { only_integer: true ,greater_than_or_equal_to: 0}  
    
    validates :code,uniqueness: { scope: :account_id, message: "产品SKU编码不可重复" }
    validates :code, format: { with: /\A[A-Z0-9\-_]+\z/,message: "编码只能是大写字母、数字、横线、下划线" }

    has_many :product_sku_properties

    before_validation :capitalize_code
     #编码自动转换成大写
     def capitalize_code
      self.code.upcase! if self.code
     end

    def product_sku_property_list
       list = ""
       self.product_sku_properties.each do |product_sku_property|
         list += product_sku_property.property.name + ":" + product_sku_property.property_value.value + ";"
       end
       list
    end
  end
end
