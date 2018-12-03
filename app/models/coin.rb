class Coin < ActiveRecord::Base
  has_one :commodity, as: :detail
  accepts_nested_attributes_for :commodity
end
