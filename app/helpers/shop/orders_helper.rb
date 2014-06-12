module Shop::OrdersHelper

  def order_cart
  	
  end

  def order_alipay
    # 提示当前订单的状态
    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
       logger.info(callback_params.inspect)
    end
  end
end
