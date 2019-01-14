class DicTitle < ActiveRecord::Base
	has_many :dic_contents, dependent: :destroy

	CATEGORY = {stamp: "邮票", coin: '硬币', paper: '纸钞'}
end
