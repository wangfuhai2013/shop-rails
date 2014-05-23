module Shop
  class PropertyValue < ActiveRecord::Base
    belongs_to :property

    validates_presence_of :property,:value,:code
    validates_uniqueness_of :code,:value,{ scope: :property, message: "同一属性的属性值或编码不可重复" }
    validates :code, format: { with: /\A[A-Z0-9\-_]+\z/,message: "编码只能是大写字母、数字、横线、下划线" }

    before_validation :capitalize_code
     #编码自动转换成大写
     def capitalize_code
     	self.code.upcase! if self.code
     end

  end
end
