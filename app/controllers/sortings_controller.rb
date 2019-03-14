class SortingsController < ApplicationController
  
  def index
    render layout: false
  end

  def product_sorting   
    if !params[:format].blank?
      if !params[:is_collect].blank? and params[:is_collect].eql?"true"
        @commodity = Collection.find_by(id: params[:format].to_i).commodity
      elsif !params[:is_list].blank? and params[:is_list].eql?"true"
        @commodity = Commodity.find(params[:format].to_i)
      elsif !params[:is_follow].blank? and params[:is_follow].eql?"true"
        @commodity = Follow.find_by(id: params[:format].to_i).commodity   
      else  
        @commodity = Commodity.find(params[:format].to_i)
      end  
      @follows = Follow.find_by(front_user_id: current_front_user, commodity_id: @commodity.id) if !@commodity.blank?
      @collections = Collection.find_by(front_user_id: current_front_user, commodity_id: @commodity.id) if !@commodity.blank?
      

      # if !Follow.find_by(id: params[:format].to_i).blank?
      #   @follows = Follow.find(params[:format].to_i).commodity
      # end  
    end
    render layout: false
  end

  def sorting_new
    @path = "/collections/do_create"
    @method = "post"
    @commodity = nil
    # binding.pry

    if !params[:format].blank?
      @commodity = Commodity.find(params[:format].to_i)
    end
    render layout: false
  end

  def sorting_edit
    @path = ""
    @method = "patch"

    if !params[:format].blank?
      @collection = Collection.find(params[:format].to_i)
      @path = "/collections/#{@collection.id}"
    end
    render layout: false
  end

  
  def sorting_collection
    @stamp_catalogs_user = current_front_user.collections.joins(:commodity).joins(:commodity=>[:catalog]).where("commodities.category = ?", "stamp").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @stamp_catalogs_all = Commodity.joins(:catalog).where("commodities.category = ?", "stamp").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @stamp_catalogs_title = @stamp_catalogs_user.map{|x| x[0]}.compact.join(",")

    @coin_catalogs_user = current_front_user.collections.joins(:commodity).joins(:commodity=>[:catalog]).where("commodities.category = ?", "coin").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @coin_catalogs_all = Commodity.joins(:catalog).where("commodities.category = ?", "coin").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @coin_catalogs_title = @coin_catalogs_user.map{|x| x[0]}.compact.join(",")

    @bill_catalogs_user = current_front_user.collections.joins(:commodity).joins(:commodity=>[:catalog]).where("commodities.category = ?", "bill").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @bill_catalogs_all = Commodity.joins(:catalog).where("commodities.category = ?", "bill").order("catalogs.catalog_no").group("catalogs.catalog_name").count

    @bill_catalogs_title = @bill_catalogs_user.map{|x| x[0]}.compact.join(",")

    render layout: false
  end

  def list_normal_collection
    @catalog_name = params[:catalog_name]
    @commodities_user = current_front_user.collections.joins(:commodity).joins(:commodity=>[:catalog]).where("catalogs.catalog_name = ?", @catalog_name).order("catalogs.catalog_no").map{|c| c.commodity}
    @commodities_all = Commodity.joins(:catalog).where("catalogs.catalog_name = ?", @catalog_name).order("catalogs.catalog_no")

    render layout: false
  end

  
end
