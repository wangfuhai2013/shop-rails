module Shop
  class OneProduct < ActiveRecord::Base

    belongs_to :product
    belongs_to :result_customer,class_name: "Shop::Customer"
    has_many :one_codes

    belongs_to :receiver_province, class_name:"Shop::District"
    belongs_to :receiver_city, class_name:"Shop::District"
    belongs_to :receiver_area, class_name:"Shop::District"
    belongs_to :logistic

    validates_presence_of :product
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

    def result_time_str
     str = ""
     str = self.result_time.strftime("%Y-%m-%d %H:%M:%S") if self.result_time
     str
    end

    def receiver_full_address
      address = ""
      address += self.receiver_province.name if self.receiver_province
      address += self.receiver_city.name if self.receiver_city
      address += self.receiver_area.name if self.receiver_area
      address += self.receiver_address
      address
    end  
  end
end
