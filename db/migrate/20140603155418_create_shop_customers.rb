class CreateShopCustomers < ActiveRecord::Migration
  def change
    create_table :shop_customers do |t|
      t.string :customer_no
      t.string :name            
      t.string :gender
      t.string :company        
      t.string :mobile
      t.string :address
      t.string :zip
      t.boolean :is_enabled      
      t.string :email
      t.string :hashed_password
      t.string :salt
      t.datetime :last_login_time
      t.string :last_login_ip
      t.integer :login_count      
      t.references :customer_type, index: true
      t.references :account, index: true
      t.references :weixin_user, index: true

      t.string :birth_date
      t.string :forgot_pwd_code
      t.datetime :forgot_pwd_time

      t.string :headimgurl

      t.timestamps

    end
  end
end
