module Shop
  class DistrictTransport < ActiveRecord::Base
    belongs_to :district

	  def price_yuan
	    format("%.2f",self.price.to_i / 100.00)    
	  end
	  def price_yuan=(value)
	    self.price = (value.to_f * 100).round
	  end  
  end
end
