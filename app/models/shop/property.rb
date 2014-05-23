module Shop
  class Property < ActiveRecord::Base
    belongs_to :category
    has_many :property_values,dependent: :destroy

    validates_presence_of :name,:code,:data_type
    validates :name,:code,uniqueness: { scope: :account_id, message: "属性名称和编码不可重复" } 
    validates :code, format: { with: /\A[A-Z0-9\-_]+\z/,message: "编码只能是大写字母、数字、横线、下划线" }

    validates :is_required, :inclusion => {:in => [true],message:"SKU属性需同时为必填属性"}, if: "is_sku == true"
    validates :is_multiple, :inclusion => {:in => [true],message:"SKU属性需同时为多选属性"}, if: "is_sku == true"    
    validates :data_type, :inclusion => {:in => ['E'],message:"SKU属性和多选属性只能是枚举类型"},
                       if: "is_sku == true || is_multiple == true"

     before_validation :capitalize_code

     #编码自动转换成大写
     def capitalize_code
     	self.code.upcase! if self.code
     end

	  def data_type_name
		  case self.data_type
		  	when 'E'
		  		'枚举类型'
		  	when 'T'
		  		'文本类型'
		  	when 'I'
		  		'整数类型'	
		  	when 'B'
		  		'布尔类型'			  			  				  					  		
		  	end
	  end
	  
	  def self.data_type_options
	    [['枚举类型', 'E'], ['文本类型', 'T'], ['整数类型', 'I'], ['布尔类型', 'B']]
	  end
  end
end
