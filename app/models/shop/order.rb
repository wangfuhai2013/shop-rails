class Shop::Order < ActiveRecord::Base

  has_many :order_items
  belongs_to :customer

  def pay_way_name
    name = "未知:" + self.pay_way
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

end
