module Shop
  class OneOrder < ActiveRecord::Base
    belongs_to :one_product
    belongs_to :customer

    has_many :one_codes

    validates_presence_of :account_id,:one_product,:customer
  end
end
