module Shop
  class OneProduct < ActiveRecord::Base

    belongs_to :product
    belongs_to :result_customer,class_name: "Shop::Customer"

    has_many :one_codes

    validates_presence_of :account_id,:product
  end
end
