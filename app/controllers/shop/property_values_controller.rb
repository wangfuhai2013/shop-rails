  class Shop::PropertyValuesController < ApplicationController
    before_action :set_property_value, only: [:show, :edit, :update, :destroy]

    # GET /property_values
    def index
      @property_values = Shop::PropertyValue.all
    end

    # GET /property_values/1
    def show
    end

    # GET /property_values/new
    def new
      @property_value = Shop::PropertyValue.new
      @property_value.property_id = params[:product_id]
      @property_value.the_order = 10
      @property_value.is_enabled = true
    end

    # GET /property_values/1/edit
    def edit
    end

    # POST /property_values
    def create
      @property_value = Shop::PropertyValue.new(property_value_params)

      if @property_value.save
        redirect_to @property_value.property, notice: '属性值已新建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /property_values/1
    def update
      if @property_value.update(property_value_params)
        redirect_to @property_value.property, notice: '属性值已修改'
      else
        render action: 'edit'
      end
    end

    # DELETE /property_values/1
    def destroy
      property = @property_value.property
      @property_value.destroy
      redirect_to property, notice: '属性值已删除.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_property_value
        @property_value = Shop::PropertyValue.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def property_value_params
        params.require(:property_value).permit(:property_id, :code,:value, :the_order, :is_enabled)
      end
  end