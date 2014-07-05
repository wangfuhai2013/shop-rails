class Shop::CustomerTypesController < ApplicationController
  before_action :set_customer_type, only: [:show, :edit, :update, :destroy]
  # GET /shop/customer_types
  def index
    @customer_types = Shop::CustomerType.where(account_id:session[:account_id]).order(level: :asc)
  end
  
  # GET /shop/customer_types/1
  def show
  end

  # GET /shop/customer_types/new
  def new
    @customer_type = Shop::CustomerType.new
    @customer_type.discount = 100
    @customer_type.level = 1
  end

  # GET /shop/customer_types/1/edit
  def edit
  end

  # POST /shop/customer_types
  def create
    @customer_type = Shop::CustomerType.new(customer_type_params)
    @customer_type.account_id = session[:account_id]

    if @customer_type.save
      redirect_to customer_types_url, notice: '类型已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/customer_types/1
  def update
    if @customer_type.update(customer_type_params)
      redirect_to customer_types_url, notice: '类型已更新.'
    else
      render action: 'edit'
    end
  end

  # DELETE /shop/customer_types/1
  def destroy
    if @customer_type.customers.size > 0
      flash[:error] = '该类型还有客户记录,不能删除'
    else      
      @customer_type.destroy
      flash[:notice] = '类型已删除.'
    end
    redirect_to customer_types_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_type
      @customer_type = Shop::CustomerType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_type_params
      params.require(:customer_type).permit(:name, :discount, :remark,:level)
    end
end
