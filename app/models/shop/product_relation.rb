module Shop
  class ProductRelation < ActiveRecord::Base
    belongs_to :product
    belongs_to :relation_product,class_name: "Shop::Product"

    validates_presence_of :product,:relation_product
  end
end
