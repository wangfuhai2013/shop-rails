module Shop
  class Property < ActiveRecord::Base
    belongs_to :category
    has_many :property_values,dependent: :destroy

    validates_presence_of :name,:data_type
    validates :name, uniqueness: { scope: :category, message: "属性名不可重复" }
    validates :is_required, :inclusion => {:in => [true],message:"SKU属性需同时为必填属性"}, if: "is_sku == true"
    validates :is_multiple, :inclusion => {:in => [true],message:"SKU属性需同时为多选属性"}, if: "is_sku == true"    
    validates :data_type, :inclusion => {:in => ['E'],message:"SKU属性和多选属性只能是枚举类型"},
                       if: "is_sku == true || is_multiple == true"

	  def data_type_name
		  case self.data_type
		  	when 'E'
		  		'枚举类型'
		  	when 'T'
		  		'文本类型'
		  	when 'I'
		  		'整数类型'		  				  					  		
		  	end
	  end
	  
	  def self.data_type_options
	    [['枚举类型', 'E'], ['文本类型', 'T'], ['整数类型', 'I']]
	  end
  end
end
