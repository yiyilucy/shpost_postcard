class Price < ActiveRecord::Base
	belongs_to :commodity
	IS_SHOW = {true => '是',false => '否'}

	def no_date
		no_date = self.commodity.no + ", " + price_date.strftime("%Y-%m-%d")
	end
end
