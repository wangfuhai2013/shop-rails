  class Shop::OneProductsController < ApplicationController
    before_action :set_shop_one_product, only: [:show, :edit, :update, :destroy,:delivery]
    before_action :set_shop_products, only: [:new, :edit, :update, :create]

    # GET /shop/one_products
    def index
      @shop_one_products = Shop::OneProduct.where(account_id: session[:account_id]).
                                            order("id DESC").page(params[:page])
                                         
    end

    # GET /shop/one_products/1
    def show
    end

    # GET /shop/one_products/new
    def new
      @shop_one_product = Shop::OneProduct.new
    end

    # GET /shop/one_products/1/edit
    def edit
    end

    # POST /shop/one_products
    def create
      @shop_one_product = Shop::OneProduct.new_one_product(params[:one_product][:product_id],session[:account_id])

      if @shop_one_product.persisted?
        redirect_to shop.one_products_url, notice: '微购商品已创建'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /shop/one_products/1
    def update
      if @shop_one_product.join_person_time > 0
        redirect_to shop.one_products_url, notice: '该微购商品已有购买人数，不可修改.'
        return
      end
      if @shop_one_product.update(shop_one_product_params)
        redirect_to shop.one_products_url, notice: '微购商品已修改.'
      else
        render action: 'edit'
      end
    end

    # DELETE /shop/one_products/1
    def destroy
      if @shop_one_product.join_person_time > 0
        redirect_to shop.one_products_url, notice: '该微购商品已有购买人数，不可修改.'
        return
      end      
      @shop_one_product.destroy
      redirect_to shop.one_products_url, notice: '微购商品已删除.'
    end

    #发货处理
    def delivery
      unless @shop_one_product.receiver_is_confirmed
        flash.now[:error] = '收货地址没有确认，不能发货'
      end
      if @shop_one_product.is_delivered
        flash.now[:error] = '访商品已发货不能重复发货'
      end
      flash.now[:error] = '发货失败，没有指定物流公司' if params[:logistic_id].blank?
      flash.now[:error] = '发货失败，没有填写快递单号' if params[:express_no].blank?
      if flash.now[:error].blank?
        @shop_one_product.logistic_id = params[:logistic_id]
        @shop_one_product.express_no = params[:express_no]
        @shop_one_product.is_delivered = true
        @shop_one_product.delivery_date = Time.now
        @shop_one_product.save
        flash.now[:notice] = "发货完成"
      end

      render action: 'show'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_shop_one_product
        @shop_one_product = Shop::OneProduct.find(params[:id])
      end

      def set_shop_products
        @shop_products = Shop::Product.where(account_id:session[:account_id],is_enabled:true)
      end

      # Only allow a trusted parameter "white list" through.
      def shop_one_product_params
        params.require(:one_product).permit(:product_id)
      end
  end