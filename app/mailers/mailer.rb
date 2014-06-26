class Mailer < ActionMailer::Base
  #default from: "from@example.com"

  def register_email(customer)    
    @customer = customer
    from = Rails.configuration.email_user
    #logger.debug("sender_name:" + @spread_message.sender_name.to_quoted_printable)
    delivery_options = { user_name: Rails.configuration.email_user,
                         password: Rails.configuration.email_password,
                         address: Rails.configuration.email_ip,
                         port: Rails.configuration.email_port,
                         authentication: Rails.configuration.email_auth.intern,
                         enable_starttls_auto: false}

    mail(from: from,to: customer.email, subject: '您已成功注册成为MC美芝华网站会员',
    	delivery_method_options: delivery_options)
  end

  def forgot_pwd_email(customer)
    @customer = customer
    from = Rails.configuration.email_user
    #logger.debug("sender_name:" + @spread_message.sender_name.to_quoted_printable)
    delivery_options = { user_name: Rails.configuration.email_user,
                         password: Rails.configuration.email_password,
                         address: Rails.configuration.email_ip,
                         port: Rails.configuration.email_port,
                         #domain: Rails.configuration.email_user.match("@(.*)")[1],
                         authentication: Rails.configuration.email_auth.intern,
                         enable_starttls_auto: false}

    ActionMailer::Base.raise_delivery_errors = true
    mail(from: from,to: customer.email, subject: '您在MC美芝华网站申请找回密码',
      delivery_method_options: delivery_options)
  end

end