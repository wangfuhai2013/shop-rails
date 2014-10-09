module Shop::OrdersHelper

  #购物车
  def order_cart  	
  end

  #生成订单并使用支付
  def order_create
    if params[:order_id]
      @order = Shop::Order.find(params[:order_id])
      return
    end
    cart = session[:cart]
    if cart.nil? || cart.items.size == 0
       render text: '购物车为空，不能创建订单'
       return
    end
    #计算折扣
    discount = 100
    customer = Shop::Customer.where(id:session[:customer_id]).take if session[:customer_id] 
    if customer
      discount = customer.customer_type.discount    
    end
    product_fee = (cart.total * discount / 100.0).round 
    #创建订单
    @order = Shop::Order.new
    @order.generate_order_no
    @order.is_paid = false
    @order.is_delivered = false
    @order.require_invoice = false

    @order.pay_way = params[:pay_way]

    #运费计算
    @order.transport_fee = 0
    if params[:transport_price] && params[:sum_volume]
       @order.transport_fee = (params[:transport_price].to_i * params[:sum_volume].to_i / 1000000000.0).round
    end

    #积分的使用
    promotion_points = 0
    @order.promotion_fee = 0
    promotion_points = params[:promotion_points].to_i if params[:promotion_points]
    promotion_points = customer.promotion_points.to_i if promotion_points > customer.promotion_points.to_i
    if promotion_points > 0
      #积分使用不超过订单金额
      promotion_points = product_fee + @order.transport_fee if 
                         promotion_points > product_fee + @order.transport_fee

      #订单使用积分，同时扣除用户积分，未付款也扣除，避免重复使用积分或造成支付失败
      @order.promotion_fee = @order.promotion_points_to_fee(promotion_points)
      customer.promotion_points = customer.promotion_points.to_i - promotion_points
      customer.save
      #积分使用记录
      promotion_history = Shop::PromotionHistory.new
      promotion_history.order =  @order
      promotion_history.change_type = 'D'
      promotion_history.change_points = promotion_points  
      promotion_history.customer =  customer
      promotion_history.save
    end
     
    @order.product_fee = product_fee     
    @order.total_fee = @order.product_fee + @order.transport_fee - @order.promotion_fee
    @order.discount = discount
    @order.customer = customer
    #收货信息
    @order.receiver_name = params[:name]
    @order.receiver_mobile = params[:mobile]    
    @order.receiver_address = params[:address]
    @order.receiver_zip = params[:zip]    
    @order.receiver_province_id = params[:province_id]    
    @order.receiver_city_id = params[:city_id]    
    @order.receiver_area_id = params[:area_id]    

    #更新客户地址信息
    customer.address = params[:address] if params[:address]
    customer.zip = params[:zip]  if params[:zip]
    customer.province_id = params[:province_id]  if  params[:province_id]
    customer.city_id = params[:city_id]  if params[:city_id] 
    customer.area_id = params[:area_id]  if params[:area_id]  
    customer.save
    #发票信息
    @order.require_invoice = true  if params[:require_invoice]
    @order.invoice_title = params[:invoice_title]    
     
    @order.save
    #订单条目
    cart.items.each do |item|
      order_item = Shop::OrderItem.new
      order_item.order = @order
      order_item.product = item.product
      order_item.product_sku = item.product_sku
      order_item.quantity = item.quantity
      order_item.price = item.product.price if item.product
      order_item.price = item.product_sku.price if item.product_sku
      order_item.discount = discount
      order_item.is_delivered = false
      order_item.save
    end
    #清空购物车
    session[:cart] = nil
  end   	
  #开始支付
  def order_pay_start
  	if params[:pay_way] == 'alipay'
      @order = Shop::Order.find(params[:order_id])
      if @order.is_paid
        render text: '该订单已付款，不可重复付款'
        return
      end
  	  @order.pay_way = 'alipay'
      @order.save      

      subject = "商品购买"
      subject = params[:subject] unless params[:subject].blank?
      return_url = ""
      return_url = params[:return_url] unless params[:return_url].blank?
      notify_url = "http://"+request.host_with_port + "/shop/orders/alipay_notify"
      redirect_to @order.alipay_url(subject,return_url,notify_url)
    else
       #render text: '支付失败，支付不方式不支持:' + params[:pay_way].to_s
    end
  end
  #支付结果
  def order_pay_end
    # 提示当前订单的状态
    @is_paid = false
    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
         #logger.info(callback_params.inspect)
         #TODO 增加account_id条件，支会多站点使用
	     @order = Shop::Order.where(order_no:params[:out_trade_no]).take
	     if @order.is_paid
	     	@is_paid = true 
	     elsif params[:trade_status] == 'TRADE_SUCCESS' || params[:trade_status] == 'TRADE_FINISHED'
	     	@order.trade_no = params[:trade_no]
	     	@order.is_paid = true
	     	@order.paid_date = Time.now
	     	@order.save
	     	@is_paid = true 
	     end	     
    else
       logger.error("aliapy notify sign verify error")
    end
  end
end
