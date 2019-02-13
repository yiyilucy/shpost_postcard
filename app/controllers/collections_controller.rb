class CollectionsController < ApplicationController
  load_and_authorize_resource :collection

  user_logs_filter only: :export, object: :collection, operation: :operation

  def index
     @collections_grid = initialize_grid(@collections.joins(:commodity).joins({commodity: :catalog}).order("collections.front_user_id, commodities.category, catalogs.id, collections.created_at"),
         :name => 'collections')
  end

  def collection_index
    if !params[:format].blank?
      @front_user_id = params[:format].to_i
      @collections = Collection.where(front_user_id: @front_user_id )
    
      @collections_grid = initialize_grid(@collections.joins(:commodity).joins({commodity: :catalog}).order("collections.front_user_id, commodities.category, catalogs.id, collections.created_at"),
         :name => 'collections')
    end
  end

  def show
    respond_with(@collection)
  end

  def new
    @collection = Collection.new
    respond_with(@collection)
  end

  def edit
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.save
    respond_with(@collection)
  end

  def update
    @collection.update(collection_params)
    respond_with(@collection)
  end

  def destroy
    @collection.destroy
    respond_with(@collection)
  end

  def export
    @operation = "export"
    if !params[:front_user_id].blank?
      @collections = @collections.where(front_user_id: params[:front_user_id].to_i)
    end
    collections = filter_collections(@collections,params)
    
    if collections.blank?
      flash[:alert] = "无数据!"
      redirect_to :action => 'index'
    else
      send_data(collection_xls_content_for(collections), :type => "text/excel;charset=utf-8; header=present", :filename => "Collections_#{Time.now.strftime("%Y%m%d")}.xls")  
    end
  end

  def filter_collections(collections, params)
    select_collections = collections.joins(:front_user).joins(:commodity).joins(:commodity=>[:catalog]).order("collections.front_user_id, commodities.category, catalogs.id, collections.created_at")

    if !params["collections"].blank?
      if !params["collections"]["f"].blank?
        params_f = params["collections"]["f"]
        if !params_f["front_users.name"].blank?
          select_collections = select_collections.where("front_users.name = ?", params_f["front_users.name"])
        end
        if !params_f["commodities.category"].blank? and !params_f["commodities.category"][0].blank?
          select_collections = select_collections.where("commodities.category = ?", params_f["commodities.category"][0])
        end
        if !params_f["catalogs.id"].blank?
          if !params_f["catalogs.id"][0].blank?
            select_collections = select_collections.where("catalogs.id = ?", params_f["catalogs.id"][0].to_i)
          end
        end
        if !params_f["commodities.no"].blank?
          select_collections = select_collections.where("commodities.no = ?", params_f["commodities.no"])
        end
        if !params_f["commodities.name"].blank?
          select_collections = select_collections.where("commodities.name = ?", params_f["commodities.name"])
        end
        
        if !params_f["created_at"].blank?
          if !params_f["created_at"]["fr"].blank?
            select_collections = select_collections.where("collections.created_at >= ?", Date.parse(params_f["created_at"]["fr"]).to_time)
          end
          if !params_f["created_at"]["to"].blank?
            select_collections = select_collections.where("collections.created_at <= ?",Date.parse(params_f["created_at"]["to"]).to_time+1.day)
          end
        end
      end
    end

    return select_collections
  end

  def collection_xls_content_for(objs)  
    sum = 0
    count = 0    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Collections"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{微信用户 商品大类 商品目录 商品编码 商品名称 收藏日期 数量 成本 备注}  
    count_row = 1
    objs.each do |obj|
      sheet1[count_row,0] = obj.front_user.name
      sheet1[count_row,1] = Commodity::CATEGORY[obj.commodity.category.to_sym]
      sheet1[count_row,2] = obj.commodity.catalog.catalog_name
      sheet1[count_row,3] = obj.commodity.no
      sheet1[count_row,4] = obj.commodity.name
      sheet1[count_row,5] = obj.created_at.strftime("%Y-%m-%d")
      sheet1[count_row,6] = obj.amount
      sheet1[count_row,7] = obj.cost
      sheet1[count_row,8] = obj.desc
      
      count_row += 1
      sum += obj.amount*obj.cost
      count += obj.amount
    end
    count_row += 1
    sheet1[count_row,0] = "总市值:"
    sheet1[count_row,1] = sum
    sheet1[count_row,2] = "汇总数:"
    sheet1[count_row,3] = count

    book.write xls_report  
    xls_report.string  
  end

  private
    def set_collection
      @collection = Collection.find(params[:id])
    end

    def collection_params
      params[:collection]
    end
end