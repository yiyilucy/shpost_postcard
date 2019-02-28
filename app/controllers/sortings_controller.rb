class SortingsController < ApplicationController
  
  def index
    render layout: false
  end

  def product_sorting
  
    if !params[:format].blank?
      if Collection.find_by(id: params[:format].to_i).blank?
        @commodity = Follow.find(params[:format].to_i).commodity

      else
        @commodity = Collection.find(params[:format].to_i).commodity
      end  
      if !Follow.find_by(id: params[:format].to_i).blank?
        @follows = Follow.find(params[:format].to_i).commodity
      end


    
    end
    render layout: false
  end

  def sorting_edit
    if !params[:format].blank?
      @collection = Collection.find(params[:format].to_i)
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
