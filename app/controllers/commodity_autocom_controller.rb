class CommodityAutocomController < ApplicationController
	load_and_authorize_resource :commodity

	autocomplete :commmodity, :name, :extra_data => [:obj]

  def autocomplete_commodity_name
    term = params[:term]
    obj_id = params[:objid]
    # binding.pry
    commodities = Commodity.where('name LIKE ? or short_name LIKE ? or common_name LIKE ?', "%#{term}%","%#{term}%","%#{term}%").accessible_by(current_ability).all
    render :json => commodities.map { |commodity| {:id => commodity.id, :label => commodity.all_name, :value => commodity.all_name, :obj => obj_id} }

  end
end