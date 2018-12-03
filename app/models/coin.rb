class Coin < ActiveRecord::Base
  has_one :commodity, as: :detail
end
