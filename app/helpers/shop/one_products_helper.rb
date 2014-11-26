module Shop::OneProductsHelper

  
  def self.included klass
    klass.class_eval do
      include Utils::WeixinHelper #引入Utils::WeixinHelper中的set_session_openid方法
      include Shop::WeixinHelper #引入Shop::WeixinHelper中的get_weixin_user方法
    end
  end

  	def one  		
      @recommend_one_products = Shop::OneProduct.joins(:product).where(
                                       is_closed:false,shop_products:{is_recommend:true}).
                                       order("shop_products.the_order ASC,id DESC").limit(9)      
      @recommend_one_products = @recommend_one_products.where(account_id:@site.account_id) if @site.has_attribute?(:account_id)
  	end
  	#商品列表
  	def one_product_list

      @one_products = Shop::OneProduct.where(is_closed:false).order("id DESC").page(params[:page]).per_page(5)
      @one_products = @one_products.where(account_id:@site.account_id)  if @site.has_attribute?(:account_id)
      #logger.debug("request.format:" + request.format)                                       
      if request.format == 'application/json'
        render json: @one_products.to_json(:include => [:product => {methods: :picture_path}])
      end
  	end
  	#商品详情
  	def one_product_detail
      @one_product = Shop::OneProduct.find(params[:id])
  	end  	

    #订单提交
    def one_order_post
       customer = get_weixin_customer         
       return if customer.nil? #应该在前一页面通过网页授权获取到openid，否在此会显示空页面

       @one_order = Shop::OneOrder.new
       @one_order.account_id = @site.account_id if @site.has_attribute?(:account_id)
       @one_order.customer = customer
       @one_order.one_product = Shop::OneProduct.find(params[:one_product_id])
       @one_order.order_person_time = params[:order_person_time]
       @one_order.is_paid = false
       @one_order.got_code_quantity = 0
       @one_order.is_got_all_code = false
       @one_order.generate_trade_no #生成支付交易号
       @one_order.save         
       if ! @one_order.persisted?
         render text:'订单创建失败，请联系网站管理员'
         logger.info("one_order_post.error" + @one_order.errors.inspect) if @one_order.errors.size > 0
         return
       end
       # @one_order.pay_success('weixin','200000000') #测试
       # pay_url /weixin/pay/start
       # return_url /cms/page/one/my_order_list

       redirect_to params[:pay_url] + "?one_order_id=" + @one_order.id.to_s + 
                                       "&site_key=" + @site.site_key + 
                                       "&return_url=" + params[:return_url]
    end

    def one_weixin_pay
      customer = get_weixin_customer         
      return if customer.nil?

      #@access_token = Utils::Weixin.get_access_token(@app_id,@secert)
     
      @return_url = "/"
      @return_url = params[:return_url] unless params[:return_url].blank?

      url = request.original_url.split('?')[0]
      @notify_url = url[0,url.rindex('/')] + "/weixin_pay_notify"   

      @out_trade_no= ""
      if params[:one_order_id]
        #一元微购
        @one_order = Shop::OneOrder.find(params[:one_order_id])
        @out_trade_no = @one_order.trade_no
        @body = @one_order.one_product.product.name + "【1元微购】" + @one_order.order_person_time.to_s + "人次"
        @total_fee = @one_order.order_person_time #* 100 #1元转换成100分
      end      

      weixin_pay(@out_trade_no,@total_fee,@body,@notify_url,customer.openid)

    end

 #支付结果通知
  def one_weixin_pay_notify
    #转换xml内容数据为params[:xml]数组，需在config/application.rb中配置
    # config.middleware.insert_after ActionDispatch::ParamsParser, ActionDispatch::XmlParamsParser    
    pay_sign_key= @site.account.pay_sign_key if  @site.account_id
    pay_sign_key= Rails.configuration.weixin_pay_sign_key  if pay_sign_key.nil?  

    xml_sign = params[:xml][:sign]
    params[:xml][:sign] = ""
    logger.debug(params[:xml])
    notify_sign = Utils::Wxpay.pay_sign(params[:xml],pay_sign_key)
    logger.debug("notify_sign:" + notify_sign)
    if notify_sign != xml_sign       
       logger.info("weixin pay notify fail: sign error or " + params[:xml].to_s) 
       logger.info("xml_sign:" + xml_sign + ",notify_sign:" + notify_sign) 
       render :text => '<xml><return_code>FAIL</return_code><return_msg>签名失败</return_msg></xml>'
       return
    end

    if params[:xml][:result_code] == 'SUCCESS'
      order = Shop::OneOrder.where(trade_no:params[:xml][:out_trade_no]).take
      if order.nil?
         logger.info("weixin pay notify fail: trade_no is not found: " + params[:xml].to_s)
         render :text => '<xml><return_code>FAIL</return_code><return_msg>订单不存在</return_msg></xml>'
      else
        order.pay_success('weixin',params[:xml][:out_trade_no])
        render :text => '<xml><return_code>SUCCESS</return_code></xml>'
      end
    else
       logger.info("weixin pay notify result fail:  " + params[:xml].to_s)
       render :text => '<xml><return_code>SUCCESS</return_code></xml>'  
    end
        
  end

  	#结果列表
  	def one_result_list
  		@one_products = Shop::OneProduct.where(is_closed:true).order("id DESC").page(params[:page]).per_page(5)
      @one_products = @one_products.where(account_id:@site.account_id) if @site.has_attribute?(:account_id)
      #logger.debug("request.format:" + request.format)                                       
      if request.format == 'application/json'
        render json: @one_products.to_json(methods: :result_time_str,
                  :include => [:product => {methods: :picture_path}] +
                              [:result_customer =>{methods: :get_headimgurl,
                                   :only =>[:id, :name]}])
      end
  	end  	

  	#结果详情
  	def one_result_detail
  		@one_product = Shop::OneProduct.find(params[:id])
  	end

    #个人订单列表
    def one_my_order_list
      @customer = get_weixin_customer
      return if @customer.nil?
      @my_one_orders = Shop::OneOrder.where(customer_id:@customer.id,is_paid:true).
                                      order("id DESC").page(params[:page]).per_page(5) if @customer 

      if request.format == 'application/json'
        render json: @my_one_orders.to_json(methods: :pay_time_str,
            :include => [:one_product => {:include => [:product =>{methods: :picture_path}]}]) if @my_one_orders
      end                                      
    end

    #个人订单查看
    def one_my_order_view
      @customer = get_weixin_customer
      return if @customer.nil?
      @my_one_order = Shop::OneOrder.find(params[:id])                                          
    end

    #获得的商品
    def one_my_product_list
      @customer = get_weixin_customer
      return if @customer.nil?
      @my_one_products = Shop::OneProduct.where(result_customer_id:@customer.id).
                                          order("id DESC").page(params[:page]).per_page(2) if @customer 

      #logger.debug("request.format:" + request.format)                                       
      if request.format == 'application/json'
        render json: @my_one_products.to_json(methods: :result_time_str,
                    :include => [:product => {methods: :picture_path}]) if @my_one_products
      end
    end

    #获得商品查看及收货地址确认
    def one_my_product_view
      @customer = get_weixin_customer
      return if @customer.nil?
      @my_one_product = Shop::OneProduct.find(params[:id]) 
      if @my_one_product.result_customer_id != @customer.id
        render text:'此商品不是您所获得，不可以查看或修改'
        return
      end
      if request.post? #确认收货地址
          #收货信息
          @my_one_product.receiver_name = params[:name]
          @my_one_product.receiver_mobile = params[:mobile]    
          @my_one_product.receiver_address = params[:address]
          @my_one_product.receiver_zip = params[:zip]    
          @my_one_product.receiver_province_id = params[:province_id]    
          @my_one_product.receiver_city_id = params[:city_id]    
          @my_one_product.receiver_area_id = params[:area_id]  
          @my_one_product.remark = params[:remark]    

          @my_one_product.receiver_is_confirmed = true
          @my_one_product.save                                              
      end                                       
    end    

end
