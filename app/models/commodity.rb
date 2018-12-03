class Commodity < ActiveRecord::Base
  belongs_to :detail, polymorphic: true
end
