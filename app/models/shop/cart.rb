class Shop::Cart

   attr_reader :items

   def initialize
   	 @items = [] 
   end

   #计算总金额（不含折扣）
   def total
     total = 0
     @items.each do |item|
       total += item.subtotal
     end
     total 
   end

   def add_product_sku(product,product_sku,quantity=1)
   	 current_item = find_item(product,product_sku)     
   	 if current_item
   	 	 current_item.increment_quantity(quantity)
   	 else
         current_item = Shop::CartItem.new(product,product_sku,quantity)
         @items << current_item
     end
                	 
   end
   def remove_product_sku(product,product_sku)
       current_item = find_item(product,product_sku)
       if current_item
         @items.delete(current_item)
      end
   end
   def change_product_sku(product,product_sku,quantity)
       current_item = find_item(product,product_sku)
       if current_item && quantity && quantity.to_i > 0
         current_item.quantity = quantity
      end
   end

   def find_item(product,product_sku)
     the_item = nil
     the_item = @items.find {|item| item.product == product } if product
     the_item = @items.find {|item| item.product_sku == product_sku } if product_sku
     the_item
   end
end