class Shop::Product < ActiveRecord::Base
  validates_presence_of :name,:category,:code
  validates :code,:name,uniqueness: { scope: :account_id, message: "产品名称的编码不可重复" }
  validates :code, format: { with: /\A[A-Z0-9\-_]+\z/,message: "编码只能是大写字母、数字、横线、下划线" }

  validates :price, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
  validates :transport_fee, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
  validates :quantity, numericality: { only_integer: true ,greater_than_or_equal_to: 0}  

  validates :discount, numericality: { only_integer: true ,greater_than_or_equal_to: 0,less_than_or_equal_to:100}

  belongs_to :category
  belongs_to :picture
  has_many :pictures
  has_many :product_properties,dependent: :destroy
  has_many :product_skus,dependent: :destroy
  
  has_and_belongs_to_many :tags

  before_validation :capitalize_code
 #编码自动转换成大写
 def capitalize_code
  self.code.upcase! if self.code
 end

end
