class Banner < ActiveRecord::Base
	has_one :import_file, as: :symbol, dependent: :destroy

	IS_SHOW = {true => '是',false => '否'}

	ORDER = {1 => '1',2 => '2',3 => '3',4 => '4',5 => '5'}
end
