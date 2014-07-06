module Shop
  class Delivery < ActiveRecord::Base
    belongs_to :order
    belongs_to :logistic

    has_many :delivery_items
  end
end
