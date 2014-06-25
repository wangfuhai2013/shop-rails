  class  Shop::OneOrdersController < ApplicationController
    before_action :set_shop_one_order, only: [:show, :edit, :update, :destroy]

    # GET /shop/one_orders
    def index
      @shop_one_orders = Shop::OneOrder.where(account_id: session[:account_id]).
                                            order("id DESC").page(params[:page])
    end

    # GET /shop/one_orders/1
    def show
    end

    # GET /shop/one_orders/new
    def new
      @shop_one_order = Shop::OneOrder.new
      render text: '后台不可新建微购订单'
    end

    # GET /shop/one_orders/1/edit
    def edit
      render text: '后台不可修改微购订单'
    end

    # POST /shop/one_orders
    def create
      @shop_one_order = Shop::OneOrder.new(shop_one_order_params)

      if @shop_one_order.save
        redirect_to shop.one_orders_url, notice: '微购订单已创建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /shop/one_orders/1
    def update
      if @shop_one_order.update(shop_one_order_params)
        redirect_to shop.one_orders_url, notice: '微购订单修改.'
      else
        render action: 'edit'
      end
    end

    # DELETE /shop/one_orders/1
    def destroy
      if @shop_one_order.is_paid
        flash[:error] = "订单已付款，不能删除条目" 
      else 
        @shop_one_order.destroy
        flash[:notice] = "微购订单删除"
      end
      redirect_to shop.one_orders_url
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_shop_one_order
        @shop_one_order = Shop::OneOrder.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def shop_one_order_params
        #后台不可修改订单
        #params.require(:one_order).permit(:one_product_id, :customer_id, :order_person_time, :pay_way, :pay_time, :is_paid, :trade_no, :got_code_quantity, :is_got_all_code)        
      end
  end