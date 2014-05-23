class Shop::Picture < ActiveRecord::Base
  belongs_to :product

  def thumb_path
    thumb_name = ""
    thumb_name = self.path[0..self.path.index('.')-1] +  "_thumb.jpg" if self.path
  end  
end
