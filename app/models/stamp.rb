class Stamp < ActiveRecord::Base
  has_one :commodity, as: :detail
end
