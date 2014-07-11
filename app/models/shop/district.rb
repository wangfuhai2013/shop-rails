module Shop
  class District < ActiveRecord::Base

    belongs_to :parent,class_name:"Shop::District"

  	def province
  	   ret = nil
       ret = self if self.level == 1
       ret = self.parent  if self.level == 2      
       ret = self.parent.parent  if self.level == 3      
       ret	
  	end
  	def city
  	   ret = nil
       ret = self if self.level == 2
       ret = self.parent if self.level == 3       
       ret
  	end

  	def area
  	   ret = nil
       ret = self if self.level == 3
       ret	
  	end

  	def full_name
  	  name = ""  	  
  	  name = self.name if self.level == 1
  	  name = self.parent.name + self.name if self.level == 2
  	  name = self.parent.parent.name + self.parent.name + self.name if self.level == 3
  	  name
  	end

  end
end
