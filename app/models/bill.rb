class Bill < ActiveRecord::Base
  has_one :commodity, as: :detail
end
