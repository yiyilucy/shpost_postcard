class Permission < ActiveRecord::Base
	has_many :user_permissions, dependent: :destroy
end
