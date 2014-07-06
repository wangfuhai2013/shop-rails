class Shop::OrderItemsController < ApplicationController
  before_action :set_shop_order_item, only: [:show, :edit, :update, :destroy]
  before_action :set_shop_product_skus, only: [:index,:new,:edit,:create,:update]
  # GET /shop/order_items
  def index
    #@shop_order_items = Shop::OrderItem.all
  end

  # GET /shop/order_items/1
  def show
  end

  # GET /shop/order_items/new
  def new
    @shop_order_item = Shop::OrderItem.new
    @shop_order_item.is_delivered = false
    @shop_order_item.order = Shop::Order.find(params[:order_id])
    render text: '后台不可新建订单条目'
  end

  # GET /shop/order_items/1/edit
  def edit
    render text: '后台不可修改订单条目'
  end

  # POST /shop/order_items
  def create
    @shop_order_item = Shop::OrderItem.new(shop_order_item_params)

    if @shop_order_item.save
      redirect_to @shop_order_item.order, notice: '订单已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/order_items/1
  def update
    if @shop_order_item.order.is_paid
      flash[:error] = "订单已付款，不能修改条目"     
      redirect_to @shop_order_item.order  
    else      
      if @shop_order_item.update(shop_order_item_params)
        redirect_to @shop_order_item.order, notice: '订单已更新.'
      else
        render action: 'edit'
      end
    end      

  end

  # DELETE /shop/order_items/1
  def destroy
    if @shop_order_item.order.is_paid
      flash[:error] = "订单已付款，不能删除条目"       
    else      
      @shop_order_item.destroy
      flash[:notice] = '订单条目已删除.'
    end  
    redirect_to @shop_order_item.order
  end

  private
    def set_shop_product_skus
      @shop_product_skus = Shop::ProductSku.all
    end  
    # Use callbacks to share common setup or constraints between actions.
    def set_shop_order_item
      @shop_order_item = Shop::OrderItem.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shop_order_item_params
      params.require(:order_item).permit(:order_id, :product_sku_id, :quantity, :price, :discount,:is_delivered)
    end
end
