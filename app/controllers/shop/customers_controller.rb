class Shop::CustomersController < ApplicationController
  before_action :set_shop_customer, only: [:show, :edit, :update, :destroy]
  before_action :set_customer_types,only: [:new,:edit,:update,:create]

  skip_before_filter :authorize, :only => [:get_districts]
  # GET /shop/customers
  def index
    account_id = session[:account_id]
    where = "1"
    where += " AND customer_no like '%#{params[:customer_no].upcase}%'" unless params[:customer_no].blank?
    where += " AND name like '%#{params[:name]}%'" unless params[:name].blank?   
    where += " AND mobile like '%#{params[:mobile]}%'" unless params[:mobile].blank?    
    where += " AND account_id = #{account_id} " unless account_id.blank?

    @shop_customers = Shop::Customer.where(where).page(params[:page]).order("id DESC")
  end

  def get_districts
    districts = Shop::District.where(parent_id:params[:id]).order(id: :desc)
    render :json => districts.to_json(only:[:id,:name])
  end
  # GET /shop/customers/1
  def show
  end
   
  # GET /shop/customers/new
  def new
    @shop_customer = Shop::Customer.new
    @shop_customer.is_enabled = true
  end

  # GET /shop/customers/1/edit
  def edit
  end

  # POST /shop/customers
  def create
    @shop_customer = Shop::Customer.new(crm_customer_params)
    @shop_customer.account_id = session[:account_id]

    @shop_customer.generate_customer_no  

    if @shop_customer.save
      redirect_to shop.customers_url, notice: '客户已创建.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /shop/customers/1
  def update
    if @shop_customer.update(crm_customer_params)
      redirect_to shop.customers_url, notice: '客户已更新.'
    else
      render action: 'edit'
    end
  end

  # DELETE /shop/customers/1
  def destroy
     if @shop_customer.orders.size > 0
      flash[:error] = "该客户有订单存在,不能删除"
    else
      flash[:notice] = "客户已删除"
      @shop_customer.destroy
    end
    redirect_to shop.customers_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shop_customer
      @shop_customer = Shop::Customer.find(params[:id])
    end
    def set_customer_types
      @customer_types = Shop::CustomerType.where(account_id:session[:account_id]).order(level: :asc)
    end    

    # Only allow a trusted parameter "white list" through.
    def crm_customer_params
      params.require(:customer).permit(:name, :gender, :mobile, :address, :zip,:company,:birth_date,
                                       :email,:password,:customer_type_id,:is_enabled,:province_id,
                                       :city_id,:area_id)  
    end
end
