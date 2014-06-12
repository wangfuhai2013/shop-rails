module Shop::OrdersHelper

  def order_cart
  	
  end

  def order_alipay
    # 提示当前订单的状态
    @is_paid = false
    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
       logger.info(callback_params.inspect)
         #TODO 增加account_id条件，支会多站点使用
	     @order = Shop::Order.where(order_no:params[:out_trade_no]).take
	     if @order.is_paid
	     	@is_paid = true 
	     elsif params[:trade_status] == 'TRADE_SUCCESS' || params[:trade_status] == 'TRADE_FINISHED'
	     	@order.trade_no = params[:trade_no]
	     	@order.is_paid = true
	     	@order.save
	     	@is_paid = true 
	     end	     
    else
       logger.error("aliapy notify sign verify error")
    end
  end
end
