class Shop::CartItem

    attr_reader :product_sku, :quantity

    def initialize(product_sku,quantity=1)
      @product_sku = product_sku
      @quantity = quantity     
    end

    def increment_quantity(quantity=1)
      @quantity += quantity
    end

    def quantity=(quantity=1)
      @quantity = quantity.to_i
    end

    def subtotal
       @product_sku.price * @quantity.to_i 
    end
end
