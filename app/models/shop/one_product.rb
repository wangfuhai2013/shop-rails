module Shop
  class OneProduct < ActiveRecord::Base

    belongs_to :product
    belongs_to :result_customer,class_name: "Shop::Customer"

    has_many :one_codes

    validates_presence_of :account_id,:product
    validates :price, numericality: { only_integer: true ,greater_than: 0}  

    def self.new_one_product(product_id,account_id)
      shop_one_product = Shop::OneProduct.new
      shop_one_product.product_id = product_id
      shop_one_product.account_id = account_id
      shop_one_product.join_person_time = 0
      shop_one_product.result_code = 0
      shop_one_product.is_closed = false
      
      max_issue_no = Shop::OneProduct.where(product:shop_one_product.product).maximum(:issue_no)
      max_issue_no = 0 unless max_issue_no
      shop_one_product.issue_no = max_issue_no + 1
      shop_one_product.price = shop_one_product.product.price / 100  #微购商品价格单位为元

      #预先随机生成微购码
      codes = []
      until codes.size == shop_one_product.price
        code = rand(shop_one_product.price) + 1
        codes.push(code) unless codes.include?(code)
      end
      codes.each do |code|
         one_code = Shop::OneCode.new()
         one_code.one_product = shop_one_product
         one_code.code = 10000000 + code
         one_code.save        
      end
=begin      
     #顺序生成
      i = 0
      shop_one_product.price.times do 
         i += 1
         one_code = Shop::OneCode.new()
         one_code.one_product = shop_one_product
         one_code.code = 10000000 + i
         one_code.save
      end
=end
       shop_one_product.save

       #处理往期未获取足够代码的订单
       one_orders = Shop::OneOrder.joins(:one_product).where(is_paid:true,is_got_all_code:false).
                                  where(shop_one_products:{product_id:product_id}).readonly(false)
       one_orders.each do |one_order|
         Shop::OneOrder.get_code(one_order,shop_one_product)
       end

       return shop_one_product
    end
  end
end
