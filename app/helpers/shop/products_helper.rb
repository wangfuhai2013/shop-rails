module Shop::ProductsHelper

	def product
        product_categories
        @new_products = Shop::Product.where(is_enabled:true).
                                      order("the_order ASC,id DESC").page(params[:page]).per_page(5)
        @recommend_products = Shop::Product.where(is_enabled:true,is_recommend:true).
                                       order("the_order ASC,id DESC").limit(15)
	end

	def product_list
		product_categories
		@product_category = Shop::Category.where(id:params[:id]).take if !!(params[:id] =~ /\A[0-9]+\z/)
		@product_category = Shop::Category.where(name:params[:id]).take unless !!(params[:id] =~ /\A[0-9]+\z/)
		where = " 1 "
		where += " AND category_id = " + @product_category.id.to_s if @product_category
        where += " AND name like '%#{params[:name]}%'" unless params[:name].blank?

		@category_products = Shop::Product.where(is_enabled:true).where(where).
		                       order("the_order ASC,id DESC").page(params[:page]).per_page(15)
		                                  
        render json: @category_products if request.format.json?
	end
	def product_tag
		@tag = Shop::Tag.find(params[:id])
		@tag_products = Shop::Product.joins(:tags).where(is_enabled:true).
		                  where(shop_products_tags:{tag_id:@tag.id}).
		                  order("the_order ASC,id DESC").page(params[:page]).per_page(15)
		                                  
        render json: @category_products if request.format.json?
	end	
	def product_show
		product_categories
		@product = Shop::Product.where("id =? AND is_enabled = ? ",params[:id],true).take
		if @product
			view_count = @product.view_count
			view_count = 0 if @product.view_count.nil?
			view_count +=1
			@product.record_timestamps=false
			@product.update_attributes(:view_count => view_count)
			@product.record_timestamps=true
		end
	end

	def product_categories
	    @product_categories = Shop::Category.where(is_enabled:true).
                                             order(the_order: :asc)
	end
end
