class FrontUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise :rememberable, :trackable
         
	has_many :collections, dependent: :destroy

	STATUS = { authen: '认证', unauthen: '未认证' }

	SEX = {male: '男', female: '女'}

	def has_follow?(commodity)
		Follow.where(commodity: commodity).exists?
	end

	def has_collection?(commodity)
		Collection.where(commodity: commodity).exists?
	end

	def get_follow(commodity)
		Follow.find_by(front_user: self, commodity: commodity)
	end

	def get_collection(commodity)
		Collection.find_by(front_user: self, commodity: commodity)
	end
end
