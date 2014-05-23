  class Shop::ProductPropertiesController < ApplicationController
    before_action :set_product_property, only: [:show, :edit, :update, :destroy]
    before_action :set_properties, only: [:new,:edit,:create,:update]
    # GET /product_properties
    def index
     # @product_properties = Shop::ProductProperty.all
    end

    # GET /product_properties/1
    def show
    end

    # GET /product_properties/new
    def new
      @product_property = Shop::ProductProperty.new
      @product_property.product_id = params[:product_id]
    end

    # GET /product_properties/1/edit
    def edit
    end

    # POST /product_properties
    def create
      @product_property = Shop::ProductProperty.new(product_property_params)

      if @product_property.save
        redirect_to @product_property.product, notice: '产品属性已创建'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /product_properties/1
    def update
      if @product_property.update(product_property_params)
        redirect_to @product_property.product, notice: '产品属性已修改.'
      else
        render action: 'edit'
      end
    end

    # DELETE /product_properties/1
    def destroy
      product = @product_property.product
      @product_property.destroy
      redirect_to product, notice: '产品属性已删除.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_product_property
        @product_property = Shop::ProductProperty.find(params[:id])
      end

      def set_properties
        product = Shop::Product.find(params[:product_id]) if params[:product_id]
        product = Shop::Product.find(params[:product_property][:product_id]) if params[:product_property] && 
                            params[:product_property][:product_id]
        @properties = Shop::Property.where("category_id = " + product.category_id.to_s +
                       " OR category_id IS NULL").where(is_enabled:true).order(the_order: :asc)
      end
      # Only allow a trusted parameter "white list" through.
      def product_property_params
        params.require(:product_property).permit(:product_id, :property_id, :property_value_id,
                                                 :input_value)
      end
  end