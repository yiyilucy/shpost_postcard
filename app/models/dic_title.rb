class DicTitle < ActiveRecord::Base
	has_many :dic_contents, dependent: :destroy

	CATEGORY = {stamp: "邮票", coin: '硬币', bill: '纸钞'}
end
