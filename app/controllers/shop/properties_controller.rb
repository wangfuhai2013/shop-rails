  class Shop::PropertiesController < ApplicationController
    before_action :set_property, only: [:show, :edit, :update, :destroy]
    before_action :set_shop_categories, only: [:index,:new,:edit,:create,:update]

    # GET /properties
    def index
      @properties = Shop::Property.all
    end

    # GET /properties/1
    def show
    end

    # GET /properties/new
    def new
      @property = Shop::Property.new
      @property.the_order = 10
      @property.is_enabled = true
    end

    # GET /properties/1/edit
    def edit
    end

    # POST /properties
    def create
      @property = Shop::Property.new(property_params)    

      if @property.save
        redirect_to @property, notice: '属性已创建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /properties/1
    def update
      if @property.update(property_params)
        redirect_to @property, notice: '属性已修改.'
      else
        render action: 'edit'
      end
    end

    # DELETE /properties/1
    def destroy
      @property.destroy
      redirect_to properties_url, notice: '属性已删除.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_property
        @property = Shop::Property.find(params[:id])
      end
    def set_shop_categories
      @shop_categories = Shop::Category.where(account_id: session[:account_id]).order(the_order: :asc)
    end
      # Only allow a trusted parameter "white list" through.
      def property_params
        params.require(:property).permit(:name, :category_id, :data_type, :is_multiple, 
                                         :is_required, :is_sku, :the_order, :is_enabled)
      end
  end