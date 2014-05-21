class Shop::PicturesController < ApplicationController
  before_action :set_shop_picture, only: [:set_cover_picture,:show, :edit, :update, :destroy]

  # GET /shop/pictures
  def index
    @shop_pictures = Shop::Picture.all
  end

  # GET /shop/pictures/1
  def show
  end

  # GET /product/pictures/new
  def set_cover_picture
    @shop_picture.product.picture = @shop_picture
    @shop_picture.product.save
    redirect_to @shop_picture.product, notice: '封面图片已设置.'
  end

  # GET /shop/pictures/new
  def new
    @shop_picture = Shop::Picture.new
    @shop_picture.product = Shop::Product.find(params[:product_id])
  end

  # GET /shop/pictures/1/edit
  def edit
  end

  # POST /shop/pictures
  def create
    @shop_picture = Shop::Picture.new(shop_picture_params)

    if upload_file_is_permitted && @shop_picture.save
      @shop_picture.path = upload(params[:picture][:path])
      @shop_picture.save
      if @shop_picture.product.picture.nil?
         @shop_picture.product.picture = @shop_picture
         @shop_picture.product.save
      end 
      redirect_to @shop_picture.product, notice: '产品图片已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/pictures/1
  def update
    if @shop_picture.update(shop_picture_params)&& upload_file_is_permitted
      if params[:picture][:path]
           delete_file(@shop_picture.path) unless @shop_picture.path.blank?
           @shop_picture.path = upload(params[:picture][:path]) 
           @shop_picture.save
      end
      redirect_to @shop_picture.product, notice: '产品图片已更新.'
    else
      render action: 'edit'
    end
  end

  # DELETE /shop/pictures/1
  def destroy
    product = @shop_picture.product
    picture_id = @shop_picture.id
    delete_file(@shop_picture.path) if !@shop_picture.path.blank?
    @shop_picture.destroy

    if product.picture_id == picture_id
         product.picture = nil 
         product.picture  = product.pictures.take if product.pictures.size > 0
         product.save
    end 

    @shop_picture.destroy
    redirect_to product, notice: '产品图片已删除.'
  end

  private

    def upload_file_is_permitted
        picture_forbid = !check_ext(params[:picture][:path]) 
        if picture_forbid
           @shop_picture.errors.add(:path, "无效的文件类型，只允许:" + 
                  Rails.configuration.upload_extname) 
           false
        else
           true
        end        
    end  
    # Use callbacks to share common setup or constraints between actions.
    def set_shop_picture
      @shop_picture = Shop::Picture.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shop_picture_params
      params.require(:picture).permit(:product_id, :description)
    end
end
