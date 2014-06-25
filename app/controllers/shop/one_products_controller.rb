  class Shop::OneProductsController < ApplicationController
    before_action :set_shop_one_product, only: [:show, :edit, :update, :destroy]
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
      @shop_one_product = Shop::OneProduct.new(shop_one_product_params)
      @shop_one_product.account_id = session[:account_id]
      @shop_one_product.join_person_time = 0
      @shop_one_product.result_code = 0
      @shop_one_product.is_closed = false
      
      max_issue_no = Shop::OneProduct.where(product:@shop_one_product.product).maximum(:issue_no)
      max_issue_no = 0 unless max_issue_no
      @shop_one_product.issue_no = max_issue_no + 1
      @shop_one_product.price = @shop_one_product.product.price / 100

      #预先随机生成微购码
      codes = []
      until codes.size == @shop_one_product.price
        code = rand(@shop_one_product.price) + 1
        codes.push(code) unless codes.include?(code)
      end
      codes.each do |code|
         one_code = Shop::OneCode.new()
         one_code.one_product = @shop_one_product
         one_code.code = 10000000 + code
         one_code.save        
      end
=begin      
     #顺序生成
      i = 0
      @shop_one_product.price.times do 
         i += 1
         one_code = Shop::OneCode.new()
         one_code.one_product = @shop_one_product
         one_code.code = 10000000 + i
         one_code.save
      end
=end
      if @shop_one_product.save
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