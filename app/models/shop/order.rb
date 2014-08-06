class Shop::Order < ActiveRecord::Base

  has_many :order_items
  belongs_to :customer

  belongs_to :receiver_province, class_name:"Shop::District"
  belongs_to :receiver_city, class_name:"Shop::District"
  belongs_to :receiver_area, class_name:"Shop::District"

  def pay_success(pay_way,trade_no)
    
  end
  
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
    
  def self.pay_way_options
      [['微信支付', 'weixin'], ['支付宝', 'alipay']]
  end

  def generate_order_no
      #order_no_prefx = store.code + Time.now.strftime('%Y%m%d') 
      order_no_prefx =  Time.now.strftime('%Y%m%d') 
      order_no_sn = '0001'
      #TODO 查询条件增加store.id
      form = Shop::Order.where("order_no like '#{order_no_prefx}%'").order("order_no DESC").take
      if form
        order_no_sn = "0000" + (form.order_no[-4,4].to_i + 1).to_s
      end    
      self.order_no = order_no_prefx + order_no_sn[-4,4]  
  end


  def alipay_url(subject,return_url,notify_url,pay_type='direct')
    options = {
      :out_trade_no      => order_no,
      :subject           => subject,  
      :total_fee          => total_fee / 100.0,
      :return_url        => return_url,
      :notify_url        => notify_url
    }
    Alipay::Service.create_direct_pay_by_user_url(options)
  end

    def total_fee_yuan
      format("%.2f",self.total_fee.to_i / 100.00)    
    end

    def product_fee_yuan
      format("%.2f",self.product_fee.to_i / 100.00)    
    end

    def transport_fee_yuan
      format("%.2f",self.transport_fee.to_i / 100.00)    
    end        
    def transport_fee_yuan=(value)
      self.transport_fee = (value.to_f * 100).round
    end  
    
    def promotion_fee_yuan
      format("%.2f",self.promotion_fee.to_i / 100.00)    
    end        

    def receiver_full_address
      address = ""
      address += self.receiver_province.name if self.receiver_province
      address += self.receiver_city.name if self.receiver_city
      address += self.receiver_area.name if self.receiver_area
      address += self.receiver_address
      address
    end      
    
    #计算积分，可覆盖
    def count_promotion_points
       self.total_fee.to_i / 100
    end
    #积分转换成抵扣金额
    def promotion_points_to_fee(points)
       points 
    end

end
