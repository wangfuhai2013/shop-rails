module Shop
  class Tag < ActiveRecord::Base
	 validates_presence_of :name
     validates :name,uniqueness: { scope: :account_id, message: "标签名称的编码不可重复" }

  	 has_and_belongs_to_many :products
  end
end
