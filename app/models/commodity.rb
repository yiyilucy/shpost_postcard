class Commodity < ActiveRecord::Base
  belongs_to :detail, polymorphic: true, dependent: :destroy
end
