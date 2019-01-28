class BillsController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: [:create, :update, :destroy], symbol: :commodity_no, object: :bill, operation: :operation
  user_logs_filter only: [:import, :export, :price_export, :image_import, :image_download, :image_destroy, :image_set_master, :batch_image_import], symbol: :file_name, object: :bill, operation: :operation

  def index
    @bills_grid = initialize_grid(Bill.joins(:commodity).order("commodities.no"),
         :name => 'bills') 
  end

  def show
  end

  def new
    @bill.commodity = Commodity.new
  end

  def edit
    @edit = true
  end

  def create
    @operation = "create"
    
    respond_to do |format|
      params = bill_params
      params["commodity_attributes"]["category"] = "bill"

      if @bill = Bill.create(params)
        @commodity_no = @bill.commodity.no
        format.html { redirect_to bills_url, notice: I18n.t('controller.create_success_notice', model: '纸钞') }
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @operation = "update"
    @commodity_no = @bill.commodity.no
    respond_to do |format|
      params = bill_params
      params["commodity_attributes"]["no"] = @bill.commodity.no
      params["commodity_attributes"]["category"] = "bill"
      # binding.pry
      if @bill.update(params)
        format.html { redirect_to bills_url, notice: I18n.t('controller.update_success_notice', model: '纸钞')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @operation = "destroy"
    @commodity_no = @bill.commodity.no
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to bills_url }
      format.json { head :no_content }
    end
  end

  def to_import
  end

  def import
    @operation = "import"
    unless request.get?
      if file = upload_bill(params[:file]['file'])  
        @file_name = File.basename(file)     
        ActiveRecord::Base.transaction do
          begin
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            current_line = 0
            is_error = false

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
            name_index = title_row.index("商品名称").blank? ? 1 : title_row.index("商品名称")
            short_name_index = title_row.index("商品简称").blank? ? 2 : title_row.index("商品简称")
            common_name_index = title_row.index("商品俗称").blank? ? 3 : title_row.index("商品俗称")
            catalog_id_index = title_row.index("商品目录").blank? ? 4 : title_row.index("商品目录")
            is_show_index = title_row.index("是否显示").blank? ? 5 : title_row.index("是否显示")
            version_index = title_row.index("版别").blank? ? 6 : title_row.index("版别")
            issue_at_index = title_row.index("发行时间").blank? ? 7 : title_row.index("发行时间")
            engrave_year_index = title_row.index("版刻年号").blank? ? 8 : title_row.index("版刻年号")
            face_value_index = title_row.index("面值").blank? ? 9 : title_row.index("面值")
            pack_spec_index = title_row.index("套系(包装规格)").blank? ? 10 : title_row.index("套系(包装规格)")
            head_index = title_row.index("正面").blank? ? 11 : title_row.index("正面")
            tail_index = title_row.index("反面").blank? ? 12 : title_row.index("反面")
            prefix_index = title_row.index("字冠").blank? ? 13 : title_row.index("字冠")
            serial_no_index = title_row.index("字号").blank? ? 14 : title_row.index("字号")
            watermark_index = title_row.index("水印").blank? ? 15 : title_row.index("水印")
            print_process_index = title_row.index("印刷工艺").blank? ? 16 : title_row.index("印刷工艺")
            
            2.upto(instance.last_row) do |line|
              catalog_id = nil
              is_show = true
              current_line = line
              rowarr = instance.row(line)

              no = rowarr[no_index].blank? ? "" : rowarr[no_index].to_s.split('.0')[0]
              name = rowarr[name_index].blank? ? "" : rowarr[name_index].to_s
              if name.blank?
                is_error = true
                txt = "缺少商品名称"
                sheet_error << (rowarr << txt)
                next
              end
              short_name = rowarr[short_name_index].blank? ? "" : rowarr[short_name_index].to_s
              common_name = rowarr[common_name_index].blank? ? "" : rowarr[common_name_index].to_s

              catalog_name = rowarr[catalog_id_index].blank? ? "" : rowarr[catalog_id_index].to_s
              if !catalog_name.blank? and !Catalog.find_by(catalog_name: catalog_name).blank?
                catalog_id = Catalog.find_by(catalog_name: catalog_name).id
              else
                is_error = true
                txt = "缺少商品目录"
                sheet_error << (rowarr << txt)
                next
              end

              if rowarr[is_show_index].to_s.eql?"否"
                is_show = false
              end

              version = rowarr[version_index].blank? ? "" : rowarr[version_index].to_s
              issue_at = rowarr[issue_at_index].blank? ? nil : DateTime.parse(rowarr[issue_at_index].to_s).strftime('%Y-%m-%d')
              engrave_year = rowarr[engrave_year_index].blank? ? "" : rowarr[engrave_year_index].to_s.split('.0')[0]
              face_value = rowarr[face_value_index].blank? ? "" : rowarr[face_value_index].to_s.split('.0')[0]
              pack_spec = rowarr[pack_spec_index].blank? ? "" : rowarr[pack_spec_index].to_s
              head = rowarr[head_index].blank? ? "" : rowarr[head_index].to_s
              tail = rowarr[tail_index].blank? ? "" : rowarr[tail_index].to_s
              prefix = rowarr[prefix_index].blank? ? "" : rowarr[prefix_index].to_s
              serial_no = rowarr[serial_no_index].blank? ? "" : rowarr[serial_no_index].to_s
              watermark = rowarr[watermark_index].blank? ? "" : rowarr[watermark_index].to_s
              print_process = rowarr[print_process_index].blank? ? "" : rowarr[print_process_index].to_s
              
              if no.blank? or Commodity.find_by(no: no).blank?
                Bill.create!(version: version, issue_at: issue_at, engrave_year: engrave_year, face_value: face_value, pack_spec: pack_spec, head: head, tail: tail, prefix: prefix, serial_no: serial_no, watermark: watermark, print_process: print_process, commodity_attributes: {name: name, short_name: short_name, common_name: common_name, catalog_id: catalog_id, category: "bill", is_show: is_show})
              elsif !Commodity.find_by(no: no).blank?
                Commodity.find_by(no: no).detail.update!(version: version, issue_at: issue_at, engrave_year: engrave_year, face_value: face_value, pack_spec: pack_spec, head: head, tail: tail, prefix: prefix, serial_no: serial_no, watermark: watermark, print_process: print_process, commodity_attributes: {name: name, short_name: short_name, common_name: common_name, catalog_id: catalog_id, category: "bill", is_show: is_show})
              end
            end

            if is_error
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message
            if is_error
              send_data(exporterrorbills_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Bills_#{Time.now.strftime("%Y%m%d")}.xls")  
            else
              redirect_to :action => 'index'
            end

          rescue Exception => e
            flash[:alert] = e.message + "第" + current_line.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end   
    end
  end

  def exporterrorbills_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Bills"  

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
    bills = filter_bills(@bills,params)
    
    if bills.blank?
      flash[:alert] = "无纸钞数据"
      redirect_to :action => 'index'
    else
      # respond_to do |format|  
      #   format.xls {   
          send_data(bill_xls_content_for(bills), :type => "text/excel;charset=utf-8; header=present", :filename => "Bills_#{Time.now.strftime("%Y%m%d")}.xls")  
      #   }
      # end
    end
  end

  def filter_bills(bills, params)
    select_bills = bills.joins(:commodity).joins(:commodity=>[:catalog]).where("commodities.category = ?", "bill").order("catalogs.id, commodities.no")

    if !params["bills"].blank?
      if !params["bills"]["f"].blank?
        params_f = params["bills"]["f"]
        if !params_f["commodities.no"].blank?
          select_bills = select_bills.where("commodities.no = ?", params_f["commodities.no"])
        end
        if !params_f["commodities.name"].blank?
          select_bills = select_bills.where("commodities.name = ?", params_f["commodities.name"])
        end
        if !params_f["catalogs.id"].blank?
          if !params_f["catalogs.id"][0].blank?
            select_bills = select_bills.where("catalogs.id = ?", params_f["catalogs.id"][0].to_i)
          end
        end
        if !params_f["commodities.is_show"].blank?
          if !params_f["commodities.is_show"][0].blank?
            select_bills = select_bills.where("commodities.is_show = ?", ((params_f["commodities.is_show"][0].eql?"t") ? true : false))
          end
        end
        if !params_f["version"].blank?
          if !params_f["version"][0].blank?
            select_bills = select_bills.where("bills.version = ?", params_f["version"][0])
          end
        end
        if !params_f["engrave_year"].blank?
          if !params_f["engrave_year"][0].blank?
            select_bills = select_bills.where("bills.engrave_year = ?", params_f["engrave_year"][0])
          end
        end
        if !params_f["face_value"].blank?
          if !params_f["face_value"][0].blank?
            select_bills = select_bills.where("bills.face_value = ?", params_f["face_value"][0])
          end
        end
        if !params_f["pack_spec"].blank?
          if !params_f["pack_spec"][0].blank?
            select_bills = select_bills.where("bills.pack_spec = ?", params_f["pack_spec"][0])
          end
        end
        if !params_f["prefix"].blank?
          if !params_f["prefix"][0].blank?
            select_bills = select_bills.where("bills.prefix = ?", params_f["prefix"][0])
          end
        end
        if !params_f["serial_no"].blank?
          if !params_f["serial_no"][0].blank?
            select_bills = select_bills.where("bills.serial_no = ?", params_f["serial_no"][0])
          end
        end
      end
    end
    return select_bills
  end

  def bill_xls_content_for(objs)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Bills"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{商品编码 商品名称 商品简称 商品俗称 商品目录 是否显示 版别 发行时间 版刻年号 面值 套系(包装规格) 正面 反面 字冠 字号 水印 印刷工艺}  
    count_row = 1
    objs.each do |obj|
      sheet1[count_row,0] = obj.commodity.no
      sheet1[count_row,1] = obj.commodity.name
      sheet1[count_row,2] = obj.commodity.short_name
      sheet1[count_row,3] = obj.commodity.common_name
      sheet1[count_row,4] = obj.commodity.catalog.try :catalog_name
      sheet1[count_row,5] = Commodity::IS_SHOW[obj.commodity.is_show]
      sheet1[count_row,6] = obj.version
      sheet1[count_row,7] = obj.issue_at
      sheet1[count_row,8] = obj.engrave_year
      sheet1[count_row,9] = obj.face_value
      sheet1[count_row,10] = obj.pack_spec
      sheet1[count_row,11] = obj.head
      sheet1[count_row,12] = obj.tail
      sheet1[count_row,13] = obj.prefix
      sheet1[count_row,14] = obj.serial_no
      sheet1[count_row,15] = obj.watermark
      sheet1[count_row,16] = obj.print_process
      
      count_row += 1
    end

    book.write xls_report  
    xls_report.string  
  end

  def price_import
    redirect_to "/prices/to_import?category=#{'bill'}" and return
  end

  def price_export
    @operation = "price_export"
    bills = filter_bills(@bills,params)
    
    if bills.blank?
      flash[:alert] = "无数据"
      redirect_to :action => 'index'
    else
      # respond_to do |format|  
      #   format.xls {   
          send_data(price_xls_content_for(bills), :type => "text/excel;charset=utf-8; header=present", :filename => "Prices_#{Time.now.strftime("%Y%m%d")}.xls")  
      #   }
      # end
    end
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
        Price.where(commodity_id: obj.commodity.id).order(:price_date).each do |p|
          sheet1[count_row,0] = obj.commodity.catalog.catalog_name
          sheet1[count_row,1] = obj.commodity.no
          sheet1[count_row,2] = obj.commodity.name
          sheet1[count_row,3] = p.price_date.strftime("%Y-%m-%d")
          sheet1[count_row,4] = p.price
          sheet1[count_row,5] = Price::IS_SHOW[p.is_show]

          count_row += 1
        end        
    end

    book.write xls_report  
    xls_report.string  
  end

  def image_index
    redirect_to image_index_import_files_path(@bill.commodity)
  end

  def to_image_import
    @symbol_id = params[:format].blank? ? nil : params[:format].to_i
  end

  def image_import
    @operation = "image_import"
    symbol = nil
    flash_message = "上传失败!"
    @file_name = nil
    unless request.get?
      if !params[:symbol_id].blank?
        symbol = Commodity.find(params[:symbol_id].to_i)
        if !symbol.blank?
          # if ImportFile.where(symbol_id: symbol.id).count < 10
            if params[:file]['file'].original_filename.include?('.jpg') or params[:file]['file'].original_filename.include?('.jpeg') or params[:file]['file'].original_filename.include?('.png') or params[:file]['file'].original_filename.include?('.bmp')
              if file_path = ImportFile.img_upload_path(params[:file]['file'], symbol, symbol.category)
                if (File.size(file_path)/1024/1024) <= I18n.t("pic_size")
                  if file = ImportFile.image_import(file_path, symbol, current_user, symbol.category)
                    @file_name = file.file_name
                    flash_message = "上传成功！"
                  end
                else
                  flash_message = "图片大小应小于#{I18n.t("pic_size")}M"
                end
              end
            else
              flash_message = "请上传jpg, jpeg, png, bmp格式图片"
            end
          # else
          #   flash_message = "一个商品最多只可上传10张图片"
          # end
        end
      end
      flash[:notice] = flash_message

      redirect_to image_index_import_files_path(symbol)           
    end
  end

  def image_download
    @operation = "image_download"

    if !params[:format].blank?
      import_file = ImportFile.find(params[:format].to_i)
      if !import_file.blank?
        file_path = import_file.file_path
        @file_name = import_file.file_name
          
        if !file_path.blank? and File.exist?(file_path)
          io = File.open(file_path)
          send_data(io.read, :type => "text/excel;charset=utf-8; header=present",              :filename => @file_name)
          io.close
        else
          redirect_to image_index_import_files_path(@bill.commodity), :notice => '文件不存在，下载失败！'
        end
      end
    end
  end

  def image_destroy
    @operation = "image_destroy"
    if !params[:format].blank?
      import_file = ImportFile.find(params[:format].to_i)
      if !import_file.blank?
        @file_name = import_file.file_name
        ImportFile.image_destroy(import_file)
      end
    end

    redirect_to image_index_import_files_path(@bill.commodity) , :notice => '删除成功'
  end

  def image_set_master
    @operation = "image_set_master"
    
    if !params[:format].blank?
      import_file = ImportFile.find(params[:format].to_i)
      if !import_file.blank?
        @file_name = import_file.file_name
        @bill.commodity.import_files.update_all is_master: false
        import_file.update is_master: true
      end
    end

    redirect_to image_index_import_files_path(@bill.commodity) , :notice => '设置成功'
  end

  def to_batch_image_import
  end

  def batch_image_import
    @operation = "batch_image_import"
    zip_direct = "#{Rails.root}/public/pic/bill/zip/"
    pic_direct = "#{Rails.root}/public/pic/bill/"
    folder_name = []
    flash_message = "上传失败!"
    desc = ""
    
    unless request.get?
      if params[:file]['file'].original_filename.include?('.zip')
        if file_path = ImportFile.img_upload_path(params[:file]['file'], nil, "bill")
          if (File.size(file_path)/1024/1024) <=  I18n.t("zip_size")
            if file = ImportFile.image_import(file_path, nil, current_user, "bill")
              @file_name = file.file_name
              desc = ImportFile.decompress(file_path, zip_direct, pic_direct, current_user, "bill")
              flash_message = "上传成功！"
              if !desc.blank?
                flash_message = "部分上传失败！"
                desc = "部分图片上传失败" + desc
                file.update desc: desc
              end
            end
          else
            flash_message = "上传文件的总大小应当不超过#{I18n.t("zip_size")}M"
          end
        end
      else
        flash_message = "请上传zip格式的压缩包"
      end
    end
    flash[:notice] = flash_message

    redirect_to bills_path
  end


  private
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def bill_params
      params[:bill].permit(:version, :issue_at, :engrave_year, :face_value, :pack_spec, :head, :tail, :prefix, :serial_no, :watermark, :print_process, commodity_attributes: [:id, :no, :name, :short_name, :common_name, :catalog_id, :category, :is_show, :pic_name])
    end

    def upload_bill(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/bill/"
        if !File.exist?("#{Rails.root}/upload")
          Dir.mkdir("#{Rails.root}/upload")          
        end
        if !File.exist?("#{Rails.root}/upload/bill/")
          Dir.mkdir("#{Rails.root}/upload/bill/")          
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
