module Shop::CustomersHelper

  def customer
  end
  def customer_register
	if request.post?
	  @is_success = false
	  if params[:password] != params[:confirm_password] 
	  	flash.now[:error] = "两次密码输入不一样"
	  	return
	  end
	  @customer = Shop::Customer.new(params.permit(:email,:name,:gender,:telephone, :address, :zip,
	  	                                           :company,:password))
	  @customer.customer_type = Shop::CustomerType.all.take
	  @customer.is_enabled = true
	  @customer.generate_customer_no 

	  @customer.save

     if @customer.errors.empty?
     	flash.now[:notice] = "您的已成功注册!"    
     	@is_success = true 	
     else
     	flash.now[:error] = "注册失败:"
     	#logger.debug("errors:"+site_feedback.errors[:email].to_s)
     	#logger.debug("errors:"+site_feedback.errors[:content].to_s)

        flash.now[:error] += "邮箱已存在或格式不正确;" unless @customer.errors[:email].blank?
        flash.now[:error] += "未填写公司名称;" unless @customer.errors[:company].blank?
        flash.now[:error] += "未填写用户名称;" unless @customer.errors[:name].blank?
        flash.now[:error] += "未填写联系电话;" unless @customer.errors[:telephone].blank?
        flash.now[:error] += "未填写地址信息;" unless @customer.errors[:address].blank?
        logger.debug(@customer.errors.inspect)
     end

	end
  end

  def customer_login
    if request.post?
     @is_success = false
      customer = Shop::Customer.authenticate(params[:email],params[:password])
      if customer 

        login_count = customer.login_count      
        login_count = 0 if login_count.nil?
        login_count += 1
        
        session[:customer_last_login_time] = customer.last_login_time
        session[:customer_last_login_ip] = customer.last_login_ip
        session[:customer_login_count] = login_count

        customer.last_login_time = Time.now
        customer.last_login_ip = request.remote_ip
        customer.login_count = login_count
        customer.save(validate: false)

        @is_success = true

        session[:customer_id] = customer.id
        session[:customer_name] = customer.name       
        

        @uri = session[:original_uri]
        session[:original_uri] = nil
        #log_info("login",params[:email] + " login success",request.remote_ip)     
      else
         flash.now[:error] = "邮箱地址或密码不正确"
      end
    end		
  end	

  def customer_logout
    session[:customer_id] = nil
    session[:customer_name] = nil
    session[:customer_last_login_time] = nil
    session[:customer_last_login_ip] = nil
    session[:customer_login_count] = nil
    #flash[:notice] = "已退出"
  end		
end
