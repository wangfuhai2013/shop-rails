class Shop::Category < ActiveRecord::Base
  validates_presence_of :code,:name
  validates_uniqueness_of :code,:name
  validates :code, format: { with: /\A[A-Z0-9]+\z/,message: "编码只能是大写字母和数字" }

  has_many :products
end
