class FrontUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
         
	STATUS = { authen: '认证', unauthen: '未认证' }

end
