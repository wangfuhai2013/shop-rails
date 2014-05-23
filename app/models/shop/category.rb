class Shop::Category < ActiveRecord::Base
  validates_presence_of :code,:name
  validates :code,:name,uniqueness: { scope: :account_id, message: "类别名称和编码不可重复" }
  validates :code, format: { with: /\A[A-Z0-9\-_]+\z/,message: "编码只能是大写字母、数字、横线、下划线" }

  has_many :products

  before_validation :capitalize_code
 #编码自动转换成大写
 def capitalize_code
 	self.code.upcase! if self.code
 end
end
