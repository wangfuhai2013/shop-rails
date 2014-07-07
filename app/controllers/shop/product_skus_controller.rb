  class Shop::ProductSkusController < ApplicationController
    before_action :set_product_sku, only: [:show, :edit, :update, :destroy]

    before_action :set_shop_sku_properties, only: [:new,:edit,:create,:update]
    
    after_action  :save_product_properties, only: [:create,:update]

    # GET /product_skus
    def index
      #@product_skus = Shop::ProductSku.all
    end

    # GET /product_skus/1
    def show
    end

    # GET /product_skus/new
    def new
      @product_sku = Shop::ProductSku.new
      @product_sku.product_id = params[:product_id]
      @product_sku.code = @product_sku.product.code
      @product_sku.is_enabled = true
    end

    # GET /product_skus/1/edit
    def edit
    end

    # POST /product_skus
    def create
      @product_sku = Shop::ProductSku.new(product_sku_params)
      @product_sku.account_id = session[:account_id]
      if @product_sku.save
        redirect_to @product_sku.product, notice: '产品SKU已创建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /product_skus/1
    def update
      if @product_sku.update(product_sku_params)
        redirect_to @product_sku.product, notice: '产品SKU已修改.'
      else
        render action: 'edit'
      end
    end

    # DELETE /product_skus/1
    def destroy
      product = @product_sku.product
      @product_sku.destroy
      redirect_to product, notice: '产品SKU已删除.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_product_sku
        @product_sku = Shop::ProductSku.find(params[:id])
      end

    #设置SKU属性集合
    def set_shop_sku_properties
        product_id = @product_sku.product_id if @product_sku
        product_id = params[:product_id] if params[:product_id]
        product_id = params[:product_sku][:product_id] if params[:product_sku] && params[:product_sku][:product_id]        

        product = Shop::Product.find(product_id)
        @sku_properties = Shop::Property.where("category_id = " + product.category_id.to_s +
                 " OR category_id IS NULL").where(is_sku:true,is_enabled:true).order(the_order: :asc)      
    end

    #保存产品属性值
    def save_product_properties
      product_sku_properties = []
      @sku_properties.each do |property|
        field_name = "property_" + property.id.to_s
        product_property = Shop::ProductProperty.find(params[field_name]) if params[field_name]
        if product_property
           product_sku_property = Shop::ProductSkuProperty.new               
           product_sku_property.property = product_property.property
           product_sku_property.property_value = product_property.property_value
           product_sku_properties.push(product_sku_property) 
        end
      end
      #TODO 已有库存或订单记录的SKU记录属性值不可以修改
      @product_sku.product_sku_properties = product_sku_properties
      @product_sku.save

    end


      # Only allow a trusted parameter "white list" through.
      def product_sku_params
        params.require(:product_sku).permit(:product_id, :code, :price_yuan, :quantity,:is_enabled)
      end
  end