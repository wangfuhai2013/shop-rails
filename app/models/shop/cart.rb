class Shop::Cart

   attr_reader :items

   def initialize
   	 @items = [] 
       @discount = 100  	
   end

   def discount
      @discount = 100 if @discount.nil?
      @discount
   end
   def discount=(discount)
      @discount = discount
   end

   def add_product_sku(product_sku,quantity=1)
   	 current_item = @items.find {|item| item.product_sku == product_sku }
   	 if current_item
   	 	current_item.increment_quantity(quantity)
   	 else
         current_item = Shop::CartItem.new(product_sku,quantity)
   	 	@items << current_item
   	 end
   end
   def remove_product_sku(product_sku)
       current_item = @items.find {|item| item.product_sku == product_sku }
       if current_item
         @items.delete(current_item)
      end
   end
   def change_product_sku(product_sku,quantity)
       current_item = @items.find {|item| item.product_sku == product_sku }
       if current_item && quantity && quantity.to_i > 0
         current_item.quantity = quantity
      end
   end
end