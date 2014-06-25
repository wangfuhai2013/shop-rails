module Shop
  class OneCode < ActiveRecord::Base
    belongs_to :one_product
    belongs_to :customer
    belongs_to :one_order

    validates_presence_of :one_product,:code
  end
end
