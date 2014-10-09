class Shop::CartItem

    attr_reader :product,:product_sku, :quantity

    def initialize(product,product_sku,quantity=1)
      @product = product
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
       total = 0
       total = @product.price * @quantity.to_i unless @product.nil?
       total = @product_sku.price * @quantity.to_i unless @product_sku.nil?
       total
    end

    def volume
       val = 0
       val = @product.product.volume * @quantity.to_i unless @product.nil?
       val = @product_sku.product.volume * @quantity.to_i unless @product_sku.nil?
    end
end
