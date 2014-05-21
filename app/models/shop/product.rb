class Shop::Product < ActiveRecord::Base
  validates_presence_of :name,:category,:code
  validates_uniqueness_of :code,:name
  validates :code, format: { with: /\A[A-Z0-9]+\z/,message: "编码只能是大写字母和数字" }

  validates :price, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
  validates :transport_fee, numericality: { only_integer: true ,greater_than_or_equal_to: 0}
  validates :quantity, numericality: { only_integer: true ,greater_than_or_equal_to: 0}  

  validates :discount, numericality: { only_integer: true ,greater_than_or_equal_to: 0,less_than_or_equal_to:100}

  belongs_to :category
  belongs_to :picture
  has_many :pictures
  has_many :product_properties,dependent: :destroy
  has_many :product_skus,dependent: :destroy
end
