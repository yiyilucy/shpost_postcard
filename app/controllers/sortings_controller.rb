class SortingsController < ApplicationController
  
  def index
    render layout: false
  end

  def product_sorting
    if !params[:format].blank?
      if !params[:is_collect].blank? and params[:is_collect].eql?"true"
        @commodity = Collection.find(params[:format].to_i).commodity
      else
        @commodity = Commodity.find(params[:format].to_i)       
      end
    end
    render layout: false
  end

  def sorting_new
    @path = "/collections/do_create"
    @method = "post"
    @commodity = Commodity.last
    

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
    render layout: false
  end

  def list_normal_collection
    render layout: false
  end

  
end
