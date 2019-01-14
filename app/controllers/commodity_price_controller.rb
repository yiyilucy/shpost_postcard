class CommodityPriceController < ApplicationController
  load_and_authorize_resource :commodity
  load_and_authorize_resource :price, through: :commodity, parent: false
  user_logs_filter only: [:create, :update, :destroy], symbol: :no_date, object: :price, operation: :operation
  user_logs_filter only: :import, symbol: :file_name, object: :price, operation: :operation

  def index
    @prices = nil
    @commodity_id = nil
    if !params[:commodity_id].blank?
      @commodity_id = params[:commodity_id].to_i
      @prices = Price.where(commodity_id: @commodity_id )
    end
    @prices_grid = initialize_grid(@prices,
         :order => 'prices.price_date',
         :order_direction => 'desc',
         :name => 'prices',
         :enable_export_to_csv => true,
         :csv_file_name => 'prices') 
    export_grid_if_requested
  end

  def show
  end

  def new
    @commodity_id = params[:commodity_id].blank? ? nil : params[:commodity_id].to_i
    if !@commodity_id.blank?
      @commodity = Commodity.find(@commodity_id)
    end
  end

  def edit
    @edit = true
  end

  def create
    @operation = "create"
    
    commodity_id = params[:commodity_id].blank? ? nil : params[:commodity_id].to_i
    respond_to do |format|
      if !commodity_id.blank?
        if !params[:price].blank? and !params[:price][:price_date].blank?
          ori_price = Price.where(commodity_id: commodity_id, price_date: Date.parse(params[:price][:price_date]).to_time)
          if !ori_price.blank?
            flash[:alert] = "该商品该日期价格已存在"
            format.html { redirect_to new_commodity_price_path(@commodity) }
            format.json { head :no_content }
          else
            @price.commodity_id = commodity_id
            @price.price = params[:price][:price].to_f.round(2)
            @price.price_date = Date.parse(params[:price][:price_date]).to_time

            if @price.save
              @no_date = @price.no_date
              format.html { redirect_to commodity_prices_path(@commodity), notice: I18n.t('controller.create_success_notice', model: '价格') }
              format.json { head :no_content }
            else
              format.html { redirect_to new_commodity_price_path(@commodity) }
              format.json { render json: @price.errors, status: :unprocessable_entity }
            end
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
        
        if @price.update(p_params)
          format.html { redirect_to commodity_prices_path(@commodity), notice: I18n.t('controller.update_success_notice', model: '价格')}
          format.json { head :no_content }
        else
          format.html { redirect_to edit_commodity_price_path(@commodity, @price) }
          format.json { render json: @price.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @operation = "destroy"
    @no_date = @price.no_date
    @price.destroy
    respond_to do |format|
      format.html { redirect_to commodity_prices_path(@commodity) }
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
        @file_name = file.split("/").last     
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
            no_index = title_row.index("商品编码").blank? ? 0 : title_row.index("商品编码")
            price_date_index = title_row.index("价格日期").blank? ? 1 : title_row.index("价格日期")
            price_index = title_row.index("价格").blank? ? 2 : title_row.index("价格")
            is_show_index = title_row.index("是否显示").blank? ? 3 : title_row.index("是否显示")

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
                  elsif params["category"].eql?"paper"
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
              if params["category"].eql?"stamp"
                redirect_to stamps_url
              elsif params["category"].eql?"coin"
                redirect_to coins_url
              elsif params["category"].eql?"paper"
                redirect_to bills_url
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

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end

        ImportFile.create! file_name: filename, file_path: file_path, user_id: current_user.id

        file_path
      end
    end
end
