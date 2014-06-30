class Shop::Picture < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_sku_property

  def thumb_path
    thumb_name = ""
    thumb_name = self.path[0..self.path.index('.')-1] +  "_thumb.jpg" if self.path
  end  
end
