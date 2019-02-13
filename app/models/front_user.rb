class FrontUser < ActiveRecord::Base
	has_many :collections, dependent: :destroy

	STATUS = { authen: '认证', unauthen: '未认证' }

end
