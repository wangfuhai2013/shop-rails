  class Shop::DeliveryItemsController < ApplicationController
    before_action :set_delivery_item, only: [:show, :edit, :update, :destroy]

    # GET /delivery_items
    def index
      @delivery_items = Shop::DeliveryItem.all
    end

    # GET /delivery_items/1
    def show
    end

    # GET /delivery_items/new
    def new
      @delivery_item = Shop::DeliveryItem.new
    end

    # GET /delivery_items/1/edit
    def edit
    end

    # POST /delivery_items
    def create
      @delivery_item = Shop::DeliveryItem.new(delivery_item_params)

      if @delivery_item.save
        redirect_to @delivery_item, notice: 'Delivery item was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /delivery_items/1
    def update
      if @delivery_item.update(delivery_item_params)
        redirect_to @delivery_item, notice: 'Delivery item was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /delivery_items/1
    def destroy
      @delivery_item.destroy
      redirect_to delivery_items_url, notice: 'Delivery item was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_delivery_item
        @delivery_item = Shop::DeliveryItem.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def delivery_item_params
        params.require(:delivery_item).permit(:delivery_id, :product_sku_id, :quantity)
      end
  end
