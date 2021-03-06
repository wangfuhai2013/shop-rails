module Shop::CustomersHelper

  def customer
    @customer = Shop::Customer.find(session[:customer_id]) if session[:customer_id]
  end
  
  def customer_order_list
    @customer = Shop::Customer.find(session[:customer_id]) if session[:customer_id]
  end

  def customer_order_show
    @order = Shop::Order.find(params[:order_id]) if session[:customer_id]
  end 

   #删除订单
  def customer_order_delete
     @order = Shop::Order.find(params[:order_id])
     if @order.is_paid
       render text: '此订单已付款，不可删除'
       return
     end
     if @order.customer_id != session[:customer_id] 
       render text: '此订单不属于您，不可删除'
       return
     end
     @order.destroy
  end    

  def customer_register
  	if request.post?
  	  @is_success = false
  	  if params[:password] != params[:confirm_password] 
  	  	flash.now[:error] = "两次密码输入不一样"
  	  	return
  	  end
      #要求检查验证码
      require_verify_code = false
      require_verify_code = Rails.configuration.shop_require_verify_code if Rails.configuration.respond_to?('shop_require_verify_code')
      if require_verify_code 
         if params[:verify_code].blank? || session[:shop_verify_code].blank? ||  
                        (session[:shop_verify_code_time].to_i + 60*10 < Time.now.to_i) || #10分钟内有效
                        params[:verify_code].to_i !=  session[:shop_verify_code].to_i   
           #logger.debug("shop_verify_code:" + session[:shop_verify_code])                    
           #logger.debug("shop_verify_code_time+600:" + (session[:shop_verify_code_time].to_i + 60*10).to_s)                    
           #logger.debug("Time.now:" + Time.now.to_i.to_s)                    
           flash.now[:error] = "验证码无效"
           return     
         end      
      end

  	  @customer = Shop::Customer.new(params.permit(:email,:name,:gender,:mobile, :address, :zip,
  	  	                                           :company,:password,:province_id,:city_id,:area_id))
  	  @customer.customer_type = Shop::CustomerType.where(account_id: @site.account_id).
                                order(level: :asc).take
  	  @customer.is_enabled = true
  	  @customer.generate_customer_no 
      birth_date = ""
      birth_date = params[:birth_year] + "." if params[:birth_year]
      birth_date += params[:birth_month] + "." if params[:birth_month]
      birth_date += params[:birth_day] if params[:birth_day]
      @customer.birth_date = birth_date

  	  @customer.save

       if @customer.errors.empty?
         update_customer_session(@customer)

         if !@customer.email.blank? && params[:email_notice].to_i == 1
           Mailer.register_email(@customer).deliver
         end

       	 flash.now[:notice] = "您的已成功注册!"    
       	 @is_success = true 	
       else
       	flash.now[:error] = "注册失败:"
       	#logger.debug("errors:"+site_feedback.errors[:email].to_s)
       	#logger.debug("errors:"+site_feedback.errors[:content].to_s)

          flash.now[:error] += "手机号已存在或格式不正确;" unless @customer.errors[:mobile].blank?
          flash.now[:error] += "邮箱已存在或格式不正确;" unless @customer.errors[:email].blank?
          flash.now[:error] += "会员类型不存在;" unless @customer.errors[:customer_type].blank?
          flash.now[:error] += "未填写公司名称;" unless @customer.errors[:company].blank?
          flash.now[:error] += "未填写用户名称;" unless @customer.errors[:name].blank?
          flash.now[:error] += "未填写联系电话;" unless @customer.errors[:telephone].blank?
          flash.now[:error] += "未填写地址信息;" unless @customer.errors[:address].blank?
          logger.debug(@customer.errors.inspect)
       end

  	end
  end

  def customer_login
    session[:original_url] = params[:from] if params[:from]
    if request.post?    
      @is_success = false
      if params[:email].blank? && params[:mobile].blank?
        flash.now[:error] = "账号不能为空"
        return
      end
      account = params[:email] unless params[:email].blank?
      account = params[:mobile] unless params[:mobile].blank?

      customer = Shop::Customer.authenticate(@site.account_id,account,params[:password])
      if customer 
        update_customer_session(customer)
        @is_success = true
        #log_info("login",params[:email] + " login success",request.remote_ip)     
      else
         flash.now[:error] = "账号或密码不正确"
      end
    end		
  end	

  def update_customer_session(customer)
    session[:customer_last_login_time] = customer.last_login_time
    session[:customer_last_login_ip] = customer.last_login_ip
    session[:customer_login_count] = customer.login_count.to_i + 1

    customer.last_login_time = Time.now
    customer.last_login_ip = request.remote_ip
    customer.login_count = customer.login_count.to_i + 1
    customer.save(validate: false)

    session[:customer_id] = customer.id
    session[:customer_name] = customer.name       
    @url = session[:original_url]
    session[:original_url] = nil
  end

  def customer_logout
    session[:customer_id] = nil
    session[:customer_name] = nil
    session[:customer_last_login_time] = nil
    session[:customer_last_login_ip] = nil
    session[:customer_login_count] = nil
    #flash[:notice] = "已退出"
  end		

  def customer_forgot_pwd_apply
    if request.post?
      @is_success = false
      customer = Shop::Customer.where(account_id:@site.account_id,email:params[:email]).take
      if customer 
         if customer.forgot_pwd_time && customer.forgot_pwd_time + 3600 > Time.now 
          logger.debug("customer.forgot_pwd_time:" + customer.forgot_pwd_time.to_s)
           flash.now[:error] = "系统已在1小时内发过找回密码的链接到您邮箱，请注册查收您的邮箱"
         else
           customer.forgot_pwd_code = Digest::SHA1.hexdigest(Time.now.to_s+rand.to_s)
           customer.forgot_pwd_time = Time.now
           customer.save     

           Mailer.forgot_pwd_email(customer).deliver

           @is_success = true
         end
        #log_info("login",params[:email] + " login success",request.remote_ip)     
      else
         flash.now[:error] = "没有找到您所输入邮箱地址对应的账号"
      end
    end
  end  

  def customer_forgot_pwd_change
    @is_success = false
    @is_invalid = true
    customer = Shop::Customer.where(account_id:@site.account_id,email:params[:email]).take
    if customer  
      if customer.forgot_pwd_code != params[:code]
        flash.now[:error] = "此找回密码链接无效"
        return
      end   
      if customer.forgot_pwd_time && customer.forgot_pwd_time + 3600 < Time.now 
         flash.now[:error] = "此找回密码链接已失效"
         return
      end 
      @is_invalid = false    
      if request.post?
        if params[:password] != params[:confirm_password] 
           flash.now[:error] = "两次密码输入不一样"
           return
        end
         #修改密码
         customer.password = params[:password]
         customer.save
         @is_success = true
      end
    else
         flash.now[:error] = "没有找到您所输入邮箱地址对应的账号"
    end
  end  

  def customer_change_profile
     @customer = Shop::Customer.find(session[:customer_id])
     if request.post?
      @is_success = false
      
      @customer.update(params.permit(:name,:gender,:address, :zip,
                                     :company,:province_id,:city_id,:area_id))
      birth_date = ""
      birth_date = params[:birth_year] + "." if params[:birth_year]
      birth_date += params[:birth_month] + "." if params[:birth_month]
      birth_date += params[:birth_day] if params[:birth_day]
      @customer.birth_date = birth_date unless birth_date.blank?

      @customer.save
      @is_success = true
    end
  end

  def customer_change_password
     if request.post?
      @is_success = false
      if params[:password] != params[:confirm_password] 
        flash.now[:error] = "两次密码输入不一样"
        return
      end

      customer = Shop::Customer.find(session[:customer_id])
      if customer.verify_password(params[:old_password]) 
         #修改密码
         customer.password = params[:password]
         customer.save
         @is_success = true
        #log_info("login",params[:email] + " login success",request.remote_ip)     
      else
         flash.now[:error] = "旧密码不正确"
      end
    end
  end


end
