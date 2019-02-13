class PricesController < ApplicationController
  load_and_authorize_resource :price
  user_logs_filter only: [:create, :update, :destroy], symbol: :no_date, object: :price, operation: :operation
  user_logs_filter only: [:import, :export], symbol: :file_name, object: :price, operation: :operation

  def index
    @prices_grid = initialize_grid(@prices.order("catalogs.id, prices.commodity_id, prices.price_date"),
         :name => 'prices',
         :enable_export_to_csv => true,
         :csv_file_name => 'prices') 
    export_grid_if_requested
  end

  def show
  end

  def new
    # @commodity_id = params[:commodity_id].blank? ? nil : params[:commodity_id].to_i
  end

  def edit
    @edit = true
    set_autocom_update(@price)
  end

  def create
    @operation = "create"
    # binding.pry
    respond_to do |format|
      if !params[:price].blank? and !params[:price][:commodity_id].blank? and !params[:price][:price_date].blank?
        commodity_id = params[:price][:commodity_id].to_i
        ori_price = Price.where(commodity_id: commodity_id, price_date: Date.parse(params[:price][:price_date]).to_time)
        if !ori_price.blank?
          flash[:alert] = "该商品该日期价格已存在"
          format.html { render action: 'new' }
          format.json { head :no_content }
        else
          @price.commodity_id = commodity_id
          @price.price = params[:price][:price].to_f.round(2)
          @price.price_date = Date.parse(params[:price][:price_date]).to_time

          if @price.save
            @no_date = @price.no_date
            format.html { redirect_to prices_url, notice: I18n.t('controller.create_success_notice', model: '价格') }
            format.json { head :no_content }
          else
            format.html { redirect_to render action: 'new' }
            format.json { render json: @price.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  def update
    @operation = "update"
    @no_date = @price.no_date
    respond_to do |format|
      p_params = price_params
      if !params[:price].blank? and !params[:price][:price].blank?
        p_params[:price] = params[:price][:price].to_f.round(2)
        p_params[:price_date] = Date.parse(params[:price][:price_date]).to_time
      end
      if @price.update(p_params)
        format.html { redirect_to prices_url, notice: I18n.t('controller.update_success_notice', model: '价格')}
        format.json { head :no_content }
      else
        format.html { redirect_to render action: 'edit' }
        format.json { render json: @price.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @operation = "destroy"
    @no_date = @price.no_date
    # commodity_id = params[:commodity_id].blank? ? nil : params[:commodity_id].to_i
    @price.destroy
    respond_to do |format|
      format.html { redirect_to prices_url }
      format.json { head :no_content }
    end
  end

  def to_import
    @category = params["category"]
  end

  def import
    @operation = "import"
    unless request.get?
      if file = upload_price(params[:file]['file'])  
        @file_name = File.basename(file)    
        ActiveRecord::Base.transaction do
          begin
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            current_line = 0
            is_error = false
            commodity = nil

            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            title_row = instance.row(1)
            no_index = title_row.index("商品编码").blank? ? 1 : title_row.index("商品编码")
            price_date_index = title_row.index("价格日期").blank? ? 3 : title_row.index("价格日期")
            price_index = title_row.index("价格").blank? ? 4 : title_row.index("价格")
            is_show_index = title_row.index("是否显示").blank? ? 5 : title_row.index("是否显示")

            2.upto(instance.last_row) do |line|
              is_show = true
              current_line = line
              rowarr = instance.row(line)

              no = rowarr[no_index].blank? ? "" : rowarr[no_index].to_s.split('.0')[0]
              # price_date = rowarr[price_date_index].blank? ? nil : Date.parse(rowarr[price_date_index]).to_time
              price_date = rowarr[price_date_index].blank? ? nil : rowarr[price_date_index].to_time
              price = rowarr[price_index].blank? ? "" : rowarr[price_index].to_f.round(2)
              if rowarr[is_show_index].to_s.eql?"否"
                is_show = false
              end

              if no.blank?
                is_error = true
                txt = "缺少商品编码"
                sheet_error << (rowarr << txt)
                next
              end

              if price_date.blank?
                is_error = true
                txt = "缺少价格日期"
                sheet_error << (rowarr << txt)
                next
              end

              if price.blank?
                is_error = true
                txt = "缺少价格"
                sheet_error << (rowarr << txt)
                next
              end

              if Commodity.find_by(no: no).blank?
                is_error = true
                txt = "商品编码错误，不存在该商品"
                sheet_error << (rowarr << txt)
                next
              else
                commodity = Commodity.find_by(no: no)
                if !commodity.category.blank? and !params["category"].blank? and !commodity.category.eql?params["category"]
                  flash[:alert] = "请导入#{I18n.t("activerecord.models.#{params["category"]}.one")}的价格!"
                  if params["category"].eql?"stamp"
                    redirect_to stamps_url and return
                  elsif params["category"].eql?"coin"
                    redirect_to coins_url and return
                  elsif params["category"].eql?"bill"
                    redirect_to bills_url and return
                  end
                end
              end
              ori_price = Price.where(commodity_id: commodity.id, price_date: price_date).first
# binding.pry
              if ori_price.blank?
                Price.create!(commodity_id: commodity.id, price_date: price_date, price: price, is_show: is_show)
              else
                ori_price.update(price: price, is_show: is_show)
              end
            end
            if is_error
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message
            if is_error
              send_data(exporterrorprices_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Prices_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              if !params["category"].blank?
                if params["category"].eql?"stamp"
                  redirect_to stamps_url
                elsif params["category"].eql?"coin"
                  redirect_to coins_url
                elsif params["category"].eql?"bill"
                  redirect_to bills_url
                end
              else
                redirect_to prices_url
              end
            end

          rescue Exception => e
            flash[:alert] = e.message + "第" + current_line.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def exporterrorprices_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Prices"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    red = Spreadsheet::Format.new :color => :red
    sheet1.row(0).default_format = blue 
    sheet1.row(0).concat title_row
    size = obj.first.size 
    count_row = 1
    obj.each do |obj|
      count = 0
      while count<=size
        sheet1[count_row,count]=obj[count]
        count += 1
      end
      count_row += 1
    end 
    book.write xls_report  
    xls_report.string  
  end

  def export
    @operation = "export"
    prices = filter_prices(@prices,params)
    
    if prices.blank?
      flash[:alert] = "无数据!"
      redirect_to :action => 'index'
    else
      # respond_to do |format|  
      #   format.xls {   
          send_data(price_xls_content_for(prices), :type => "text/excel;charset=utf-8; header=present", :filename => "Prices_#{Time.now.strftime("%Y%m%d")}.xls")  
      #   }
      # end
    end
  end

  def filter_prices(prices, params)
    select_prices = prices.joins(:commodity).joins(:commodity=>[:catalog]).order("catalogs.id, commodities.no, price_date")

    if !params["prices"].blank?
      if !params["prices"]["f"].blank?
        params_f = params["prices"]["f"]
        if !params_f["commodities.no"].blank?
          select_prices = select_prices.where("commodities.no = ?", params_f["commodities.no"])
        end
        if !params_f["commodities.name"].blank?
          select_prices = select_prices.where("commodities.name = ?", params_f["commodities.name"])
        end
        if !params_f["catalogs.id"].blank?
          if !params_f["catalogs.id"][0].blank?
            select_prices = select_prices.where("catalogs.id = ?", params_f["catalogs.id"][0].to_i)
          end
        end
        if !params_f["is_show"].blank? and !params_f["is_show"][0].blank?
          select_prices = select_prices.where("prices.is_show = ?", ((params_f["is_show"][0].eql?"t") ? true : false))
        end
        if !params_f["price_date"].blank?
          if !params_f["price_date"]["fr"].blank?
            select_prices = select_prices.where("prices.price_date >= ?", Date.parse(params_f["price_date"]["fr"]).to_time)
          end
          if !params_f["price_date"]["to"].blank?
            select_prices = select_prices.where("prices.price_date <= ?",Date.parse(params_f["price_date"]["to"]).to_time+1.day)
          end
        end
        # binding.pry
        if !params_f["price"].blank?
          if !params_f["price"]["fr"].blank?
            select_prices=select_prices.where("prices.price >= ?",params_f["price"]["fr"].to_i)
          end
          if !params_f["price"]["to"].blank?
            select_prices=select_prices.where("prices.price <= ?",params_f["price"]["to"].to_i)
          end
        end
      end
    end

    return select_prices
  end

  def price_xls_content_for(objs)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Prices"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{商品目录 商品编码 商品名称 价格日期 价格 是否显示}  
    count_row = 1
    objs.each do |obj|
      sheet1[count_row,0] = obj.commodity.catalog.catalog_name
      sheet1[count_row,1] = obj.commodity.no
      sheet1[count_row,2] = obj.commodity.name
      sheet1[count_row,3] = obj.price_date.strftime("%Y-%m-%d")
      sheet1[count_row,4] = obj.price
      sheet1[count_row,5] = Price::IS_SHOW[obj.is_show]

      count_row += 1
    end

    book.write xls_report  
    xls_report.string  
  end
            
            

  private
    def set_price
      @price = Price.find(params[:id])
    end

    def price_params
      params.require(:price).permit(:price_date, :price, :is_show, :commodity_id)
    end

    def upload_price(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/price/"
        if !File.exist?("#{Rails.root}/upload")
          Dir.mkdir("#{Rails.root}/upload")          
        end
        if !File.exist?("#{Rails.root}/upload/price/")
          Dir.mkdir("#{Rails.root}/upload/price/")          
        end
        filename = "#{Time.now.to_f}_#{file.original_filename}"
        file_ext = filename.split('.').last
        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        
        size = File.size(file_path) 

        ImportFile.create! file_name: filename, file_path: file_path, user_id: current_user.id, file_ext: file_ext, size: size

        file_path
      end
    end
end
