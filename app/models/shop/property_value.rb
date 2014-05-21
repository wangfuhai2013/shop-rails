module Shop
  class PropertyValue < ActiveRecord::Base
    belongs_to :property

    validates_presence_of :property,:value,:code
    validates_uniqueness_of :code,:value,{ scope: :property, message: "属性值或编码不可重复" }
  end
end
