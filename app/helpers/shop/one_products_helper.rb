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

    #订单提交
    def one_order_post
      if request.post?
         customer = get_customer
         if customer.nil?
            return
         end
         @one_order = Shop::OneOrder.new
         @one_order.account_id = @site.account_id
         @one_order.customer = customer
         @one_order.one_product = Shop::OneProduct.find(params[:one_product_id])
         @one_order.order_person_time = params[:order_person_time]
         @one_order.is_paid = false
         @one_order.got_code_quantity = 0
         @one_order.is_got_all_code = false
         @one_order.save
         if ! @one_order.persisted?
           render text:'订单创建失败，请联系网站管理员'
           logger.info("one_order_post.error" + @one_order.errors.inspect) if @one_order.errors.size > 0
           return
         end
         # @one_order.pay_success('weixin','200000000') #测试
         redirect_to params[:pay_url] + "?one_order_id=" + @one_order.id.to_s + 
                                         "&site_key=" + @site.site_key
      else
        render text:'当前访问操作不合法'  
      end
    end   

  	#结果列表
  	def one_result_list
  		@one_products = Shop::OneProduct.where(is_closed:true).order("id DESC").limit(9)   
  	end  	

  	#结果详情
  	def one_result_detail
  		@one_product = Shop::OneProduct.find(params[:id])
  	end

    #个人订单列表
    def one_my_order_list
      @customer = get_customer
      @my_one_orders = Shop::OneOrder.where(customer_id:@customer.id,is_paid:true).
                                      order("id DESC").limit(9) if @customer 
    end
    #获得的商品
    def one_my_product_list
      @customer = get_customer
      @my_one_products = Shop::OneProduct.where(result_customer_id:@customer.id).
                                          order("id DESC").limit(9) if @customer 
    end
    
    #通过微信标识获取用户身份
    def get_customer
      if @weixin_user.nil?
          render text:'请在微信中访问'
          return nil
      end
      customer = Shop::Customer.where(weixin_user_id:@weixin_user.id).take
      if customer.nil?
        customer = Shop::Customer.new
        customer.weixin_user_id = @weixin_user.id
        customer.account_id = @site.account_id
        customer.name = @weixin_user.nickname
        customer.headimgurl = @weixin_user.headimgurl_size

        customer.save(validate: false)
        if customer.name.nil?
          customer.name = '微购网友' + (10000000 + customer.id).to_s
          customer.save(validate: false)
        end
         
      end
      return customer
    end

end
