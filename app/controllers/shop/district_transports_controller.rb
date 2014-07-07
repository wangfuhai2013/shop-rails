  class Shop::DistrictTransportsController < ApplicationController
    before_action :set_district_transport, only: [:show, :edit, :update, :destroy]
    before_action :set_district_provinces, only: [:new, :edit, :update, :create]

    skip_before_filter :authorize, :only => [:get_price]

    # GET /district_transports
    def index
      @district_transports = Shop::DistrictTransport.where(account_id: session[:account_id])
    end

   def get_price
    districtTransport = Shop::DistrictTransport.where(district_id:params[:id]).take
    price = 0
    price = districtTransport.price if districtTransport
    render :text => price.to_s
   end

    # GET /district_transports/1
    def show
    end

    # GET /district_transports/new
    def new
      @district_transport = Shop::DistrictTransport.new
    end

    # GET /district_transports/1/edit
    def edit
    end

    # POST /district_transports
    def create
      @district_transport = Shop::DistrictTransport.new(district_transport_params)
      @district_transport.account_id = session[:account_id]

      if @district_transport.save
        redirect_to district_transports_url, notice: '运费已创建.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /district_transports/1
    def update
      if @district_transport.update(district_transport_params)
        redirect_to district_transports_url, notice: '运费已修改'
      else
        render action: 'edit'
      end
    end

    # DELETE /district_transports/1
    def destroy
      @district_transport.destroy
      redirect_to district_transports_url, notice: '运费已删除.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_district_transport
        @district_transport = Shop::DistrictTransport.find(params[:id])
      end

      def set_district_provinces
         @district_provinces = Shop::District.where(level:1)
      end

      # Only allow a trusted parameter "white list" through.
      def district_transport_params
        params.require(:district_transport).permit(:district_id, :price_yuan)
      end
  end
