  class Shop::LogisticsController < ApplicationController
    before_action :set_logistic, only: [:show, :edit, :update, :destroy]

    # GET /logistics
    def index
      @logistics = Shop::Logistic.all
    end

    # GET /logistics/1
    def show
    end

    # GET /logistics/new
    def new
      @logistic = Shop::Logistic.new
    end

    # GET /logistics/1/edit
    def edit
    end

    # POST /logistics
    def create
      @logistic = Shop::Logistic.new(logistic_params)
      @logistic.account_id = session[:account_id]
      if @logistic.save
        redirect_to logistics_url, notice: '物流公司已创建'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /logistics/1
    def update
      if @logistic.update(logistic_params)
        redirect_to logistics_url, notice: '物流公司已修改'
      else
        render action: 'edit'
      end
    end

    # DELETE /logistics/1
    def destroy
      if Shop::Delivery.where(logistic_id:@logistic.id).size > 0      
        flash[:error] = "该物流公司有发货数据，不可以删除"
      else
        @logistic.destroy
        flash[:notice] = '物流公司已删除'
      end
      
      redirect_to logistics_url
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_logistic
        @logistic = Shop::Logistic.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def logistic_params
        params.require(:logistic).permit(:name)
      end
  end