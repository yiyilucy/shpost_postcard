class DicContent < ActiveRecord::Base
	belongs_to :dic_title
	IS_SHOW = {true => '是',false => '否'}
end
