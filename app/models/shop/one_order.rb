module Shop
  class OneOrder < ActiveRecord::Base
    belongs_to :one_product
    belongs_to :customer

    has_many :one_codes

    validates_presence_of :account_id,:one_product,:customer

	  def pay_way_name
	    name = "未知:" + self.pay_way.to_s
	    case self.pay_way
	    	when 'weixin'
	    		name = '微信支付'
	    	when 'alipay'
	    		name = '支付宝'
	    end
	    name
	  end 

    #支付成功
    def pay_success(pay_way,trade_no)
      if self.is_paid
      	#已支付
      	return
      end
      self.pay_way = pay_way
      self.pay_time = Time.now
      self.pay_millisecond = self.pay_time.strftime("%3N")
      self.is_paid = true
      self.trade_no = trade_no
      self.save

      #获取微购码
      Shop::OneOrder.get_code(self,self.one_product)
    end

    def self.get_code(one_order,one_product)
      #获取微购码
      Shop::OneCode.where(one_product_id:one_product.id,one_order_id:nil,customer_id:nil).
                    limit(one_order.order_person_time - one_order.got_code_quantity).
                    update_all(one_order_id:one_order.id,customer_id:one_order.customer_id,updated_at:Time.now)
      #更新订单
      got_code_quantity = Shop::OneCode.where(one_order_id:one_order.id).count
      if got_code_quantity >= one_order.order_person_time
        one_order.is_got_all_code = true
        if got_code_quantity > one_order.order_person_time
          logger.error("got_code_quantity greater than order_person_time with one_order_id:" + one_order.id.to_s)        
          got_code_quantity = one_order.order_person_time
        end
      end
      one_order.got_code_quantity = got_code_quantity
      one_order.save
      #更新商品
      one_product.join_person_time = Shop::OneCode.where(one_product_id:one_product.id).
                                          where("customer_id is not null").count  
      one_product.save
    end
  end
end
