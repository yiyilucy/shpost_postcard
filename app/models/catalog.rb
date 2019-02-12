class Catalog < ActiveRecord::Base
  has_many :commodities
  
  CATALOG_TYPE = {stamp: "邮票", coin: '硬币', bill: '纸钞'}
  IS_SHOW = {true => '是',false => '否'}

  # def is_show_name
  #   if is_show
  #      name = "是"
  #   else
  #      name = "否"
  #   end
  # end

  # def catalog_type_name
  #   if catalog_type.eql?"stamp"
  #     name = "邮票"
  #   elsif catalog_type.eql?"coin"
  #     name = "硬币"
  #   elsif catalog_type.eql?"bill"
  #     name = "纸币"
  #   end
  # end
end
