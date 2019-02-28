class Follow < ActiveRecord::Base
  belongs_to :commodity
  belongs_to :front_user
end
