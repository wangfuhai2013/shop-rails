class Shop::Customer < ActiveRecord::Base
  belongs_to :customer_type

  belongs_to :province, class_name:"Shop::District"
  belongs_to :city, class_name:"Shop::District"
  belongs_to :area, class_name:"Shop::District"

  has_many  :orders
  has_many  :promotion_histories
  
  validates_presence_of :name,:customer_type
  validate :mobile_or_email_presence

  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ ,:allow_blank => true
  validates_uniqueness_of :email,allow_blank: true,uniqueness: { scope: :account_id, message: "邮箱不可重复" }
  validates_uniqueness_of :mobile,allow_blank: true,uniqueness: { scope: :account_id, message: "手机号不可重复" }

  validate :password_non_blank

    def mobile_or_email_presence
     # if !(mobile.blank? ^ email.blank?) #二选一
      if mobile.blank? && email.blank？
        errors.add(:base, "邮箱或手机号至少填写一个")
      end
    end

    def self.authenticate(account_id,email_or_mobile,password)
      
      if email_or_mobile.include?('@')
        user = Shop::Customer.where(account_id:account_id,email:email_or_mobile).take
      else
        user = Shop::Customer.where(account_id:account_id,mobile:email_or_mobile).take
      end

      if user
        expected_password = encrypted_password(password,user.salt)
        #logger.debug("user.hashed_password:" + user.hashed_password + ",expected_password:" + expected_password)
        if user.hashed_password != expected_password || !user.is_enabled
          user = nil        
        end
      end
      user
    end
    
    def verify_password(password)
      expected_password = Shop::Customer.encrypted_password(password,self.salt)
      logger.debug("expected_password:"+expected_password+",hashed_password:"+self.hashed_password)
      if self.hashed_password == expected_password
        true       
      else
        false
      end
    end

    def password
      @password
    end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_salt
    self.hashed_password = Shop::Customer.encrypted_password(pwd,self.salt)
  end
  def password_non_blank
    errors.add(:password,"missing password") if hashed_password.blank?
    
  end
  def self.encrypted_password(password,slat)
    Digest::SHA1.hexdigest(password+slat)
  end
  def create_salt
      self.salt =  rand.to_s
  end

  def as_json options=nil
    options ||= {}
    options[:except] = [:hashed_password,:salt]
    super options
  end

  def gender_name
  	 name = '未知'
     name = '男' if self.gender == 'M'
     name = '女' if self.gender == 'F'
     name
  end
  def self.gender_options
     [['男', 'M'], ['女', 'F']]
  end

  def get_headimgurl(blank_headimg="")
     return self.headimgurl unless self.headimgurl.blank?
     return blank_headimg  if  self.headimgurl.blank?
  end

  def generate_customer_no
=begin
    #生成规则：门店前缀+7位全局序号
    customer_no_prefx = store.code
    customer_no_sn = '0000001'
    customer = Crm::Customer.where("customer_no like '#{customer_no_prefx}%'").order("customer_no DESC").take
    if customer
      customer_no_sn = "0000000" + (customer.customer_no[-7,7].to_i + 1).to_s
    end    
    self.customer_no = customer_no_prefx + customer_no_sn[-7,7]
=end
    #生成规则：门店前缀+日期+4位单天序号
    #customer_no_prefx = store.code + Time.now.strftime('%Y%m%d')
    customer_no_prefx =  Time.now.strftime('%Y%m%d')
    customer_no_sn = '0001'
    customer = Shop::Customer.where(account_id:self.account_id).where("customer_no like '#{customer_no_prefx}%'").order("customer_no DESC").take
    if customer
      customer_no_sn = "0000" + (customer.customer_no[-4,4].to_i + 1).to_s
    end    
    self.customer_no = customer_no_prefx + customer_no_sn[-4,4] 
  end

  def as_json options=nil
    logger.debug("customer.as_json...")
    options ||= {}
    options[:only] = ((options[:only] || []) + [:id, :customer_no,:name,:gender])    
    super options
  end

end
