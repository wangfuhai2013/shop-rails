module Shop
  class PromotionHistory < ActiveRecord::Base
    belongs_to :order
    belongs_to :customer
  end
end
