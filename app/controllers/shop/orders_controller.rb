class Shop::OrdersController < ApplicationController
  before_action :set_shop_order, only: [:show, :edit, :update, :destroy]

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
      params.require(:order).permit(:order_no, :pay_way, :total_fee, :product_fee, :transport_fee, :is_paid, :is_delivered, :paid_date, :delivery_date, :delivery_address, :remark, :openid)
    end
end
