module Shop::OneProductsHelper

  	def one  		
      @recommend_one_products = Shop::OneProduct.joins(:product).where(is_closed:false,shop_products:{is_recommend:true}).
                                       order("shop_products.the_order ASC,id DESC").limit(9)                               
  	end
  	#商品列表
  	def one_product_list
      @one_products = Shop::OneProduct.where(is_closed:false).order("id DESC").limit(9)   
  	end
  	#商品详情
  	def one_product_detail
      @one_product = Shop::OneProduct.find(params[:id])
  	end  	
  	#结果列表
  	def one_result_list
  		@one_products = Shop::OneProduct.where(is_closed:true).order("id DESC").limit(9)   
  	end  	
  	#结果详情
  	def one_result_detail
  		@one_product = Shop::OneProduct.find(params[:id])
  	end
end
