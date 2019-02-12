module ApplicationHelper
	def commodity_select_autocom(obj_id)       
       concat text_field_tag('p_commodity_name',@cname, 'data-autocomplete' => "/commodity_autocom/autocomplete_commodity_name?objid=#{obj_id}" )
       hidden_field(obj_id.to_sym,"commodity_id");
    end
end
