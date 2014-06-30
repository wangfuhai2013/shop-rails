  class Shop::PropertyValuesController < ApplicationController
    before_action :set_property_value, only: [:show, :edit, :update, :destroy]

    # GET /property_values
    def index
     # @property_values = Shop::PropertyValue.all
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
     if upload_file_is_permitted && @property_value.save
        @property_value.picture_path = upload(params[:property_value][:picture_path])
        @property_value.save
        redirect_to @property_value.property, notice: '属性值已新建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /property_values/1
    def update
      if upload_file_is_permitted && @property_value.update(property_value_params)
        if params[:property_value][:picture_path]
           delete_file(@property_value.picture_path) if !@property_value.picture_path.blank?
           @property_value.picture_path = upload(params[:property_value][:picture_path]) 
           @property_value.save
        end
        redirect_to @property_value.property, notice: '属性值已修改'
      else
        render action: 'edit'
      end
    end

    # DELETE /property_values/1
    def destroy
      property = @property_value.property
      if Shop::ProductProperty.where(property_value_id:@property_value.id).size > 0
         flash[:error] = "已有产品绑定该属性值，不可删除"
      else
         delete_file(@property_value.picture_path) if !@property_value.picture_path.blank?
         @property_value.destroy
         flash[:notice] = "属性值已删除"
      end
      redirect_to property
    end

    private
    def upload_file_is_permitted
        file_forbid = !check_ext(params[:property_value][:picture_path]) 
        if file_forbid
           @shop_category.errors.add(:picture_path, "无效的文件类型，只允许:" + 
                  Rails.configuration.upload_extname) 
           false
        else
           true
        end        
    end    
      # Use callbacks to share common setup or constraints between actions.
      def set_property_value
        @property_value = Shop::PropertyValue.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def property_value_params
        params.require(:property_value).permit(:property_id, :code,:value, :the_order, :is_enabled)
      end
  end