module Shop
  class DistrictTransport < ActiveRecord::Base
    belongs_to :district
  end
end
