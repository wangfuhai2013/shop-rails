class Shop::CustomerType < ActiveRecord::Base
  has_many :customers

  validates_presence_of :name,:discount
  validates_uniqueness_of :name,uniqueness: { scope: :account_id, message: "类型名称不可重复" }
end
