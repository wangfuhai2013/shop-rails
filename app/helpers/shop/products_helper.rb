module Shop::ProductsHelper

	def product
        product_categories
        @new_products = Shop::Product.where(account_id: @site.account_id,is_enabled:true).
                                      order("the_order ASC,id DESC").page(params[:page]).per_page(5)
        @recommend_products = Shop::Product.where(account_id: @site.account_id,is_enabled:true,is_recommend:true).
                                         order("the_order ASC,id DESC").limit(5)
	end
	def product_list
		product_categories
		@product_category = Shop::Category.find(params[:id])

		@category_products = Shop::Product.where(account_id: @site.account_id,is_enabled:true,
			                                     category_id:@product_category.id).
		                                    order("the_order ASC,id DESC").page(params[:page]).per_page(8)
		                                  
        render json: @category_products if request.format.json?
	end
	def product_show
		product_categories
		@product = Shop::Product.where("id =? AND is_enabled = ? ",params[:id],true).take
		view_count = @product.view_count
		view_count = 0 if @product.view_count.nil?
		view_count +=1
		@product.record_timestamps=false
		@product.update_attributes(:view_count => view_count)
		@product.record_timestamps=true
	end

	def product_categories
	    @product_categories = Shop::Category.where(account_id: @site.account_id,is_enabled:true).
                                             order(the_order: :asc)
	end
end
