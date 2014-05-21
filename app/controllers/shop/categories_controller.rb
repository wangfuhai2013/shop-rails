class Shop::CategoriesController < ApplicationController
  before_action :set_shop_category, only: [:show, :edit, :update, :destroy]

  # GET /shop/categories
  def index
    @shop_categories = Shop::Category.where(account_id: session[:account_id]).
                                   order(the_order: :asc)
  end

  # GET /shop/categories/1
  def show
  end

  # GET /shop/categories/new
  def new
    @shop_category = Shop::Category.new
    @shop_category.the_order = 10
    @shop_category.is_enabled = true    
  end

  # GET /shop/categories/1/edit
  def edit
  end

  # POST /shop/categories
  def create
    @shop_category = Shop::Category.new(shop_category_params)
    @shop_category.account_id = session[:account_id]
    if upload_file_is_permitted && @shop_category.save
      @shop_category.picture_path = upload(params[:category][:picture_path])
      @shop_category.save
      redirect_to shop.categories_url, notice: '类别已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/categories/1
  def update
    if @shop_category.update(shop_category_params) && upload_file_is_permitted
      if params[:category][:picture_path]
         delete_file(@shop_category.picture_path) if !@shop_category.picture_path.blank?
         @shop_category.picture_path = upload(params[:category][:picture_path]) 
         @shop_category.save
      end
      redirect_to shop.categories_url, notice: '类别已更新.'
    else
      render action: 'edit'
    end
  end

  # DELETE /shop/categories/1
  def destroy
   if @shop_category.products.size > 0
      flash[:error] = "该类别还有信息数据，不可以删除"
    else
      delete_file(@shop_category.picture_path) if !@shop_category.picture_path.blank?
      @shop_category.destroy
      flash[:notice] = '类别已删除.'
    end
    redirect_to shop.categories_url
  end

  private
    def upload_file_is_permitted
        file_forbid = !check_ext(params[:category][:picture_path]) 
        if file_forbid
           @shop_category.errors.add(:picture_path, "无效的文件类型，只允许:" + 
                  Rails.configuration.upload_extname) 
           false
        else
           true
        end        
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_shop_category
      @shop_category = Shop::Category.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shop_category_params
      params.require(:category).permit(:name, :code, :the_order,:is_enabled)
    end
end
