class Shop::Order < ActiveRecord::Base

has_many :order_items

def pay_way_name
  case self.pay_way
  	when 'weixin'
  		'微信支付'
  	when 'alipay'
  		'支付宝'
  	end
  end
  
  def self.pay_way_options
    [['微信支付', 'weixin'], ['支付宝', 'alipay']]
  end
end
