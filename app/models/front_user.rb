class FrontUser < ActiveRecord::Base
<<<<<<< HEAD
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
         
	has_many :collections, dependent: :destroy

	STATUS = { authen: '认证', unauthen: '未认证' }

end
