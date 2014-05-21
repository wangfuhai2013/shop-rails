module Shop
  class ProductProperty < ActiveRecord::Base
    belongs_to :product
    belongs_to :property
    belongs_to :property_value

    validates_presence_of :product,:property
  end
end
