class Shop::OrdersController < ApplicationController
  before_action :set_shop_order, only: [:show, :edit, :update, :destroy]

  skip_before_filter :authorize,:verify_authenticity_token,
                 only: [:add_to_cart,:remove_from_cart,:empty_cart,:change_product_quantity,:create_order]
  layout  false, only: [:add_to_cart,:remove_from_cart,:empty_cart,:change_product_quantity,:create_order]

  #加入购物车
  def add_to_cart
    if request.post? && params[:product_id] && params[:property_value]
       @cart = session[:cart] ||= Shop::Cart.new
       #TODO 支持多个属性选sku
       product_sku = Shop::ProductSku.joins(:product_sku_properties).
                                      where(product_id:params[:product_id],
                                      :shop_product_sku_properties => {property_value_id:params[:property_value]}).take
      if product_sku
        quantity = params[:quantity].to_i if params[:quantity]
        quantity = 1 if quantity < 1
        @cart.add_product_sku(product_sku,quantity)
        render json: {is_success:"true",message:"添加成功",cart_item_count:@cart.items.size}
      else
        #商品不存存或已下架
        render json: {is_success:"false",message:"商品不存存或已下架"}
      end
    else
       render json: {is_success:"false",message:"参数不全"}
    end
  end

  #改变购物车中商品数量
  def change_product_quantity
    @cart = session[:cart] ||= Shop::Cart.new
    product_sku = Shop::ProductSku.find(params[:id]) if params[:id]
    if product_sku
       @cart.change_product_sku(product_sku,params[:quantity])
    end
    render json: {is_success:"true",message:"已从购物车移出商品" }
  end

  #从购物车移出商品
  def remove_from_cart
    @cart = session[:cart] ||= Shop::Cart.new
    product_sku = Shop::ProductSku.find(params[:id]) if params[:id]
    if product_sku
       @cart.remove_product_sku(product_sku)
    end
    render json: {is_success:"true",message:"已从购物车移出商品" }
  end

  #清空购物车
  def empty_cart
    session[:cart] = nil
    render json: {is_success:"true",message:"购物车已清空" }
  end

  #生成订单并使用支付
  def create_order
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
    total = cart.total * discount / 100
    #创建订单
    order = Shop::Order.new
    order.generate_order_no
    order.is_paid = false
    order.is_delivered = false
    order.pay_way = params[:pay_way]
    order.transport_fee = 0   
    order.product_fee = total     
    order.total_fee = order.product_fee + order.transport_fee
    order.discount = discount
    order.customer = customer
    #收货信息
    order.receiver_name = params[:name]
    order.receiver_mobile = params[:mobile]    
    order.receiver_address = params[:address]
    order.receiver_zip = params[:zip]    
    order.save
    #订单条目
    cart.items.each do |item|
      order_item = Shop::OrderItem.new
      order_item.order = order
      order_item.product_sku = item.product_sku
      order_item.quantity = item.product_sku.quantity
      order_item.price = item.product_sku.price
      order_item.discount = discount
      order_item.save
    end
    #清空购物车
    session[:cart] = nil
    if order.pay_way == 'alipay'
      subject = "商品购买"
      subject = params[:subject] unless params[:subject].blank?
      return_url = ""
      return_url = params[:return_url] unless params[:return_url].blank?
      notify_url = "http://"+request.host_with_port + "/" +  "orders/alipay_notify"
      redirect_to order.alipay_url(subject,return_url,notify_url)
    else
       render text: '支付失败，支付不方式不支持:' + order.pay_way
    end
  end 

  #接收支付宝支付结果通知
  def alipay_notify
     notify_params = params.except(*request.path_parameters.keys)
   # 先校验消息的真实性
    if Alipay::Sign.verify?(notify_params) && Alipay::Notify.verify?(notify_params)
      # 获取交易关联的订单
      order = Shop::Order.where(order_no:params[:out_trade_no],
                                 account_id: session[:account_id],is_paid:false).take
      logger.error("can't find unpaid order_no:" + params[:out_trade_no]) unless order
      logger.info("order_no:" + params[:out_trade_no] + " trade_status:" + params[:trade_status])
      case params[:trade_status]
      when 'WAIT_BUYER_PAY'
        # 交易开启
      when 'WAIT_SELLER_SEND_GOODS'
        # 买家完成支付
      when 'TRADE_FINISHED'
        # 交易完成
        order.is_paid = true if order
      when 'TRADE_CLOSED'
        # 交易被关闭
      end
      order.save if order

      render :text => 'success' # 成功接收消息后，需要返回纯文本的 ‘success’，否则支付宝会定时重发消息，最多重试7次。 
    else
      render :text => 'error'
    end
  end

  # GET /shop/orders
  def index
    @shop_orders = Shop::Order.where(account_id: session[:account_id]).order("id DESC").page(params[:page])
  end

  # GET /shop/orders/1
  def show
  end

  # GET /shop/orders/new
  def new
    @shop_order = Shop::Order.new
  end

  # GET /shop/orders/1/edit
  def edit
  end

  # POST /shop/orders
  def create
    @shop_order = Shop::Order.new(shop_order_params)
    @shop_order.account_id = session[:account_id]
    if @shop_order.save
      redirect_to shop.orders_url, notice: '订单已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/orders/1
  def update
    if @shop_order.is_paid
      flash[:error] = "订单已付款，不能删除条目" 
      redirect_to shop.orders_url      
    else    
      if @shop_order.update(shop_order_params)
        redirect_to shop.orders_url, notice: '订单已更新.'
      else
        render action: 'edit'
      end
    end
  end

  # DELETE /shop/orders/1
  def destroy
    if @shop_order.is_paid
      flash[:error] = "订单已付款，不能删除条目" 
    else 
      @shop_order.destroy
      flash[:notice] = '订单已删除.'
    end
    redirect_to shop.orders_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shop_order
      @shop_order = Shop::Order.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shop_order_params
      params.require(:order).permit(:order_no, :pay_way, :total_fee, :product_fee, :transport_fee,
             :is_paid, :is_delivered, :paid_date, :delivery_date, :receiver_address, :remark, :openid)
    end
end