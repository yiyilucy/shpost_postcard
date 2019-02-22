class ListTabsController < ApplicationController
 
  def index
    render layout: false
  end

  def product
    render layout: false
  end

  def list_normal
    @commodities = Commodity.where(catalog_id:params[:format].to_i)
  	
    @catalogs = Catalog.find(params[:format].to_i)
    
    render layout: false
  end
  


end
