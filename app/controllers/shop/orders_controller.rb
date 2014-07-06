class Shop::OrdersController < ApplicationController
  before_action :set_shop_order, only: [:delivery,:show, :edit, :update, :destroy]
  skip_before_filter :authorize,:verify_authenticity_token, only: [:add_to_cart,
                     :remove_from_cart,:empty_cart,:change_product_quantity,:alipay_notify]
  layout  false, only: [:add_to_cart,:remove_from_cart,:empty_cart,
                        :change_product_quantity,:alipay_notify]

  #加入购物车
  def add_to_cart
    if request.post? && params[:product_id] && params[:property_value]
       @cart = session[:cart] ||= Shop::Cart.new
       #TODO 支持多个属性选sku
       product_sku = Shop::ProductSku.joins(:product_sku_properties).
                                      where(product_id:params[:product_id],
                                      :shop_product_sku_properties => {property_value_id:params[:property_value]}).take
      if product_sku && product_sku.price.to_i > 0
        quantity = params[:quantity].to_i if params[:quantity]
        quantity = 1 if quantity < 1
        @cart.add_product_sku(product_sku,quantity)
        render json: {is_success:"true",message:"添加成功",cart_item_count:@cart.items.size}
      else
        #商品不存存或已下架
        render json: {is_success:"false",message:"商品不存在或已下架"}
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
        # 买家完成支付,等发货
      when 'TRADE_SUCCESS'
        # 交易完成(直接收款)
        order.is_paid = true if order
      when 'TRADE_FINISHED'
        # 交易成功并且完成
        order.is_paid = true if order
      when 'TRADE_CLOSED'
        # 交易被关闭
      end
      order.trade_no = params[:trade_no] if order
      order.paid_date = Time.now if order
      order.save if order

      render :text => 'success' # 成功接收消息后，需要返回纯文本的 ‘success’，否则支付宝会定时重发消息，最多重试7次。 
    else
      render :text => 'error'
    end
  end

 #发货
  def delivery

    if @shop_order.is_delivered || !@shop_order.is_paid 
      flash[:error] = "该订单已是发货状态，不能再次发货" if @shop_order.is_delivered
      flash[:error] = "该订单还未付款，不能发货" unless @shop_order.is_paid
    else
      #选中的表单条目
      item_ids = []
      item_ids = params[:item_ids] if params[:item_ids]
      ids = '0'
      item_ids.each do |id|
        ids += "," + id.to_s
      end
      items = Shop::OrderItem.where("ID IN (" + ids + ")").where(is_delivered:false)
      if items.size == 0
        flash[:error] = '申请出货操作失败，没有选中未发货的订单条目'
        redirect_to @shop_order
        return
      end
      #生成发货单
      delivery = Shop::Delivery.new
      delivery.order = @shop_order
      delivery.logistic_id = params[:logistic_id]
      delivery.invoice_no = params[:invoice_no]
      delivery.save
      
      items.each do |item|
        delivery_item = Shop::DeliveryItem.new
        delivery_item.delivery = delivery
        delivery_item.product_sku_id = item.product_sku_id
        delivery_item.quantity = item.quantity
        delivery_item.save
        
        item.is_delivered = true
        item.delivery = delivery
        item.save
      end

      #更新订单发货状态
      if @shop_order.order_items.where(is_delivered:false).size == 0
         @shop_order.is_delivered = true
         @shop_order.delivery_date = Time.now
         @shop_order.save
         flash[:notice] = "全部商品发货完成"
      else
         flash[:notice] = "部分商品发货完成"
      end
      
    end
    redirect_to @shop_order
  end

  # GET /shop/orders
  def index
    @shop_orders = Shop::Order.where(account_id: session[:account_id]).order("id DESC").page(params[:page])
  end

  # GET /shop/orders/1
  def show
    @logistics = Shop::Logistic.where(account_id: session[:account_id])
  end

  # GET /shop/orders/new
  def new
    @shop_order = Shop::Order.new
    render text: '后台不可新建订单'
  end

  # GET /shop/orders/1/edit
  def edit
   # render text: '后台不可修改订单'
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
      flash[:error] = "订单已付款，不能修改条目" 
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
                                    :is_paid, :paid_date,:is_delivered, :delivery_date, :remark, 
                                    :receiver_name,:receiver_mobile,:receiver_address, :receiver_zip,
                                    :require_invoice,:invoice_title,:openid,:receiver_province_id,
                                    :receiver_city_id,:receiver_area_id)
    end
end