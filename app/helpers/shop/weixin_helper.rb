module Shop

  module WeixinHelper


#微信支付处理(JSAPI)
  def weixin_pay(out_trade_no,total_fee,body,notify_url,openid)
      @app_id = @site.account.app_id  if  @site.account_id
      @app_secret = @site.account.app_secret if  @site.account_id
      @pay_sign_key= @site.account.pay_sign_key if  @site.account_id
      @mch_id = @site.account.mch_id if  @site.account_id

      @app_id = Rails.configuration.weixin_app_id  if @app_id.nil?
      @app_secret = Rails.configuration.weixin_app_secret  if @app_secret.nil?
      @pay_sign_key= Rails.configuration.weixin_pay_sign_key  if @pay_sign_key.nil?    
      @mch_id= Rails.configuration.weixin_mch_id  if @mch_id.nil? 

      #构造支付订单接口参数
      pay_params = {
        :appid => @app_id,
        :mch_id => @mch_id,
        :body => body,           
        :nonce_str => Digest::MD5.hexdigest(Time.now.to_s).to_s,
        :notify_url => notify_url, #'http://szework.com/weixin/pay/notify',#get_notify_url(),
        :out_trade_no => out_trade_no, #out_trade_no, #'2014041311110001'
        :total_fee => total_fee, 
        :trade_type => 'JSAPI',   
        :openid =>  openid,
        :spbill_create_ip => request.remote_ip #TODO 支持反向代理
      }

      pay_order = Utils::Wxpay.unifiedorder(pay_params,@pay_sign_key)
      if pay_order["return_code"][0] == 'SUCCESS' && pay_order["result_code"][0] == 'SUCCESS'
        @package_params = {
          :appId => @app_id,
          :timeStamp => Time.now.to_i,
          :nonceStr => Digest::MD5.hexdigest(Time.now.to_s).to_s,
          :package => "prepay_id=" + pay_order["prepay_id"][0],
          :signType => "MD5" 
        }
        @package_params[:paySign] = Utils::Wxpay.pay_sign(@package_params,@pay_sign_key)
      else         
         logger.info("one_weixin_pay.error:" + pay_order["return_msg"].to_s + ";" + 
             pay_order["err_code_des"].to_s )
         return false
      end   
      return true       
  end

    #通过微信标识获取用户身份
    def get_weixin_customer(customer=nil)
      @app_id = @site.account.app_id  if  @site.account_id
      @app_secret = @site.account.app_secret if  @site.account_id
      @app_id = Rails.configuration.weixin_app_id  if @app_id.nil?
      @app_secret = Rails.configuration.weixin_app_secret  if @app_secret.nil?

      session_key = "openid"
      session_key = @openid_key unless @openid_key.blank? #兼容微站多个站点共用组件      
      if @weixin_user.nil? && session[session_key].blank? #@weixin_user由微站框架提供，其他应用无此对象
          #render text:'请在微信中访问'
          #开发环境使用默认openid，避免跳入微信环境 o6hyyjlRoyQelo6YgWstsRJjSBb8
          params[:openid] = 'oLJPFuPaNInbz4s8486pxoRiTSqk' if Rails.env == 'development' 
          set_session_openid(session_key,@app_id,@app_secret)
          return if performed?
      end
      logger.debug("@weixin_user:" + @weixin_user.to_s)
      openid = session[session_key] unless session[session_key].blank?
      openid = @weixin_user.openid if @weixin_user   #微站获取的数据   

      return if customer && customer.openid == openid #已登录用户的openid与接口获取的一致

      customer = Shop::Customer.where(openid:openid).take if customer.nil?
      if customer.nil?
        customer = Shop::Customer.new
        customer.account_id = @site.account_id if @site.has_attribute?(:account_id)        
        customer.openid = openid
        if @weixin_user      
          customer.name = @weixin_user.nickname
          customer.headimgurl = @weixin_user.headimgurl_size
        else
           weixin_userinfo = Utils::Weixin.get_userinfo(openid,@app_id,@app_secret)     
           customer.name = weixin_userinfo["nickname"] if weixin_userinfo["nickname"]
           customer.headimgurl = weixin_userinfo["headimgurl"]  if weixin_userinfo["headimgurl"]   
        end        
        customer.save(validate: false)
        #logger.debug("customer.error:" + customer.errors.full_messages)
        if customer.name.nil?
           customer.name = '微购网友' + (10000000 + customer.id.to_i).to_s 
           customer.save(validate: false)
        end
      end
      return customer
    end

  end
end
