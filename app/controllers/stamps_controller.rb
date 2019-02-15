class StampsController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: [:create, :update, :destroy], symbol: :commodity_no, object: :stamp, operation: :operation
  user_logs_filter only: [:import, :export, :price_export, :image_import, :image_download, :image_destroy, :image_set_master, :batch_image_import], symbol: :file_name, object: :stamp, operation: :operation
  require 'zip'

  def index
    @stamps_grid = initialize_grid(Stamp.joins(:commodity).order("commodities.no"),
         :name => 'stamps')   
  end

  def show
  end

  def new
    @stamp.commodity = Commodity.new
  end

  def edit
    @edit = true
  end

  def create
    @operation = "create"
    respond_to do |format|
      params = stamp_params
      params["commodity_attributes"]["category"] = "stamp"

      if @stamp = Stamp.create(params)
        @commodity_no = @stamp.commodity.no
    
        format.html { redirect_to stamps_url, notice: I18n.t('controller.create_success_notice', model: '邮票') }
        format.json { head :no_content }
      else
        format.html { render action: 'new' }
        format.json { render json: @stamp.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @operation = "update"
    @commodity_no = @stamp.commodity.no
    respond_to do |format|
      params = stamp_params
      params["commodity_attributes"]["no"] = @commodity_no
      params["commodity_attributes"]["category"] = "stamp"
      # binding.pry
      if @stamp.update(params)
        format.html { redirect_to stamps_url, notice: I18n.t('controller.update_success_notice', model: '邮票')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stamp.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @operation = "destroy"
    @commodity_no = @stamp.commodity.no
    @stamp.destroy
    respond_to do |format|
      format.html { redirect_to stamps_url }
      format.json { head :no_content }
    end
  end

  def to_import
  end

  def import
    @operation = "import"
    unless request.get?
      if file = upload_stamp(params[:file]['file'])   
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
            serial_no_index = title_row.index("志号").blank? ? 6 : title_row.index("志号")
            format_index = title_row.index("版式").blank? ? 7 : title_row.index("版式")
            theme_index = title_row.index("题材").blank? ? 8 : title_row.index("题材")
            version_index = title_row.index("版别").blank? ? 9 : title_row.index("版别")
            designer_index = title_row.index("设计者").blank? ? 10 : title_row.index("设计者")
            ori_author_index = title_row.index("原作者").blank? ? 11 : title_row.index("原作者")
            engrave_author_index = title_row.index("雕作者").blank? ? 12 : title_row.index("雕作者")
            issue_at_index = title_row.index("发行时间").blank? ? 13 : title_row.index("发行时间")
            issue_unit_index = title_row.index("发行机构").blank? ? 14 : title_row.index("发行机构")
            print_unit_index = title_row.index("印刷机构").blank? ? 15 : title_row.index("印刷机构")
            gum_index = title_row.index("背胶").blank? ? 16 : title_row.index("背胶")
            circulation_index = title_row.index("发行量").blank? ? 17 : title_row.index("发行量")
            set_amount_index = title_row.index("全套枚数").blank? ? 18 : title_row.index("全套枚数")
            page_amount_index = title_row.index("整版枚数").blank? ? 19 : title_row.index("整版枚数")
            perforation_index = title_row.index("齿孔度").blank? ? 20: title_row.index("齿孔度")
            specification_index = title_row.index("规格").blank? ? 21 : title_row.index("规格")
            editor_index = title_row.index("责任编辑").blank? ? 22 : title_row.index("责任编辑")

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

              serial_no = rowarr[serial_no_index].blank? ? "" : rowarr[serial_no_index].to_s.split('.0')[0]
              format = rowarr[format_index].blank? ? "" : rowarr[format_index].to_s
              theme = rowarr[theme_index].blank? ? "" : rowarr[theme_index].to_s
              version = rowarr[version_index].blank? ? "" : rowarr[version_index].to_s
              designer = rowarr[designer_index].blank? ? "" : rowarr[designer_index].to_s
              ori_author = rowarr[ori_author_index].blank? ? "" : rowarr[ori_author_index].to_s
              engrave_author = rowarr[engrave_author_index].blank? ? "" : rowarr[engrave_author_index].to_s
              issue_at = rowarr[issue_at_index].blank? ? nil : DateTime.parse(rowarr[issue_at_index].to_s).strftime('%Y-%m-%d')
              issue_unit = rowarr[issue_unit_index].blank? ? "" : rowarr[issue_unit_index].to_s
              print_unit = rowarr[print_unit_index].blank? ? "" : rowarr[print_unit_index].to_s
              gum = rowarr[gum_index].blank? ? "" : rowarr[gum_index].to_s
              circulation = rowarr[circulation_index].blank? ? "" : rowarr[circulation_index].to_s.split('.0')[0]
              set_amount = rowarr[set_amount_index].blank? ? "" : rowarr[set_amount_index].to_s.split('.0')[0]
              page_amount = rowarr[page_amount_index].blank? ? "" : rowarr[page_amount_index].to_s.split('.0')[0]
              perforation = rowarr[perforation_index].blank? ? "" : rowarr[perforation_index].to_s.split('.0')[0]
              specification = rowarr[specification_index].blank? ? "" : rowarr[specification_index].to_s
              editor = rowarr[editor_index].blank? ? "" : rowarr[editor_index].to_s

              if no.blank? or Commodity.find_by(no: no).blank?
                Stamp.create!(serial_no: serial_no, format: format, theme: theme, version: version, designer: designer, ori_author: ori_author, engrave_author: engrave_author, issue_at: issue_at, issue_unit: issue_unit, print_unit: print_unit, gum: gum, circulation: circulation, set_amount: set_amount, page_amount: page_amount, perforation: perforation, specification: specification, editor: editor, commodity_attributes: {name: name, short_name: short_name, common_name: common_name, catalog_id: catalog_id, category: "stamp", is_show: is_show})
              elsif !Commodity.find_by(no: no).blank?
                Commodity.find_by(no: no).detail.update!(serial_no: serial_no, format: format, theme: theme, version: version, designer: designer, ori_author: ori_author, engrave_author: engrave_author, issue_at: issue_at, issue_unit: issue_unit, print_unit: print_unit, gum: gum, circulation: circulation, set_amount: set_amount, page_amount: page_amount, perforation: perforation, specification: specification, editor: editor, commodity_attributes: {name: name, short_name: short_name, common_name: common_name, catalog_id: catalog_id, category: "stamp", is_show: is_show})
              end
            end

            if is_error
              flash_message << "有部分信息导入失败！"
            end
            flash[:notice] = flash_message
            if is_error
              send_data(exporterrorstamps_xls_content_for(sheet_error,title_row),  
              :type => "text/excel;charset=utf-8; header=present",  
              :filename => "Error_Stamps_#{Time.now.strftime("%Y%m%d")}.xls") 
              redirect_to :action => 'index' 
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

  def exporterrorstamps_xls_content_for(obj,title_row)
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Stamps"  

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
    stamps = filter_stamps(@stamps,params)
    
    if stamps.blank?
      flash[:alert] = "无邮票数据"
      redirect_to :action => 'index'
    else
      # respond_to do |format|  
      #   format.xls {   
          send_data(stamp_xls_content_for(stamps), :type => "text/excel;charset=utf-8; header=present", :filename => "Stamps_#{Time.now.strftime("%Y%m%d")}.xls")  
      #   }
      # end
    end
  end

  def filter_stamps(stamps, params)
    select_stamps = stamps.joins(:commodity).joins(:commodity=>[:catalog]).where("commodities.category = ?", "stamp").order("catalogs.id, commodities.no")

    if !params["stamps"].blank?
      if !params["stamps"]["f"].blank?
        params_f = params["stamps"]["f"]
        if !params_f["commodities.no"].blank?
          select_stamps = select_stamps.where("commodities.no = ?", params_f["commodities.no"])
        end
        if !params_f["commodities.name"].blank?
          select_stamps = select_stamps.where("commodities.name = ?", params_f["commodities.name"])
        end
        if !params_f["catalogs.id"].blank?
          if !params_f["catalogs.id"][0].blank?
            # select_stamps = select_stamps.where("catalogs.catalog_name = ?", params_f["catalogs.catalog_name"])
            select_stamps = select_stamps.where("catalogs.id = ?", params_f["catalogs.id"][0].to_i)
          end
        end
        if !params_f["commodities.is_show"].blank?
          if !params_f["commodities.is_show"][0].blank?
            select_stamps = select_stamps.where("commodities.is_show = ?", ((params_f["commodities.is_show"][0].eql?"t") ? true : false))
          end
        end
        if !params_f["serial_no"].blank?
          select_stamps = select_stamps.where("stamps.serial_no = ?", params_f["serial_no"])
        end
        if !params_f["format"][0].blank?
          if !params_f["format"][0].blank?
            select_stamps = select_stamps.where("stamps.format = ?", params_f["format"][0])
          end
        end
        if !params_f["theme"][0].blank?
          if !params_f["theme"][0].blank?
            select_stamps = select_stamps.where("stamps.theme = ?", params_f["theme"][0])
          end
        end
        if !params_f["version"].blank?
          select_stamps = select_stamps.where("stamps.version = ?", params_f["version"])
        end
        if !params_f["designer"].blank?
          select_stamps = select_stamps.where("stamps.designer = ?", params_f["designer"])
        end
        if !params_f["issue_at"].blank?
          if !params_f["issue_at"]["fr"].blank?
            select_stamps = select_stamps.where("stamps.issue_at >= ?",params_f["issue_at"]["fr"].to_time)
          end
          if !params_f["issue_at"]["to"].blank?
            select_stamps = select_stamps.where("stamps.issue_at <= ?",params_f["issue_at"]["to"].to_time+1.day)
          end
        end
        if !params_f["issue_unit"].blank?
          select_stamps = select_stamps.where("stamps.issue_unit = ?", params_f["issue_unit"])
        end
        if !params_f["issue_unit"].blank?
          select_stamps = select_stamps.where("stamps.issue_unit = ?", params_f["issue_unit"])
        end
      end
    end
    
    return select_stamps
  end

  def stamp_xls_content_for(objs)  
    
    xls_report = StringIO.new  
    book = Spreadsheet::Workbook.new  
    sheet1 = book.create_worksheet :name => "Stamps"  

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10  
    sheet1.row(0).default_format = blue  

    sheet1.row(0).concat %w{商品编码 商品名称 商品简称 商品俗称 商品目录 是否显示 志号 版式 题材 版别 设计者 原作者 雕作者 发行时间 发行机构 印刷机构 背胶 发行量 全套枚数 整版枚数 齿孔度 规格 责任编辑}  
    count_row = 1
    objs.each do |obj|
      sheet1[count_row,0] = obj.commodity.no
      sheet1[count_row,1] = obj.commodity.name
      sheet1[count_row,2] = obj.commodity.short_name
      sheet1[count_row,3] = obj.commodity.common_name
      sheet1[count_row,4] = obj.commodity.catalog.try :catalog_name
      sheet1[count_row,5] = Commodity::IS_SHOW[obj.commodity.is_show]
      sheet1[count_row,6] = obj.serial_no
      sheet1[count_row,7] = obj.format
      sheet1[count_row,8] = obj.theme
      sheet1[count_row,9] = obj.version
      sheet1[count_row,10] = obj.designer
      sheet1[count_row,11] = obj.ori_author
      sheet1[count_row,12] = obj.engrave_author
      sheet1[count_row,13] = obj.issue_at.blank? ? "" : obj.issue_at.strftime("%Y-%m-%d")
      sheet1[count_row,14] = obj.issue_unit
      sheet1[count_row,15] = obj.print_unit
      sheet1[count_row,16] = obj.gum
      sheet1[count_row,17] = obj.circulation
      sheet1[count_row,18] = obj.set_amount
      sheet1[count_row,19] = obj.page_amount
      sheet1[count_row,20] = obj.perforation
      sheet1[count_row,21] = obj.specification
      sheet1[count_row,22] = obj.editor

      count_row += 1
    end

    book.write xls_report  
    xls_report.string  
  end

  def price_import
    redirect_to "/prices/to_import?category=#{'stamp'}" and return
  end

  def price_export
    @operation = "price_export"
    stamps = filter_stamps(@stamps,params)
    
    if stamps.blank?
      flash[:alert] = "无数据"
      redirect_to :action => 'index'
    else
      # respond_to do |format|  
      #   format.xls {   
          send_data(price_xls_content_for(stamps), :type => "text/excel;charset=utf-8; header=present", :filename => "Prices_#{Time.now.strftime("%Y%m%d")}.xls")  
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
    redirect_to image_index_import_files_path(@stamp.commodity)
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
                if (File.size(Rails.root.to_s + file_path)/1024/1024) <= I18n.t("pic_upload_param.pic_size")
                  if file = ImportFile.image_import(file_path, symbol, current_user, symbol.category)
                    @file_name = file.file_name
                    flash_message = "上传成功！"
                  end
                else
                  flash_message = "图片大小应小于#{I18n.t("pic_upload_param.pic_size")}M"
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
        file_path = import_file.absolute_path
        @file_name = import_file.file_name
          
        if !file_path.blank? and File.exist?(file_path)
          io = File.open(file_path)
          send_data(io.read, :type => "text/excel;charset=utf-8; header=present",              :filename => @file_name)
          io.close
        else
          redirect_to image_index_import_files_path(@stamp.commodity), :notice => '文件不存在，下载失败！'
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
        import_file.image_destroy!
      end
    end

    redirect_to image_index_import_files_path(@stamp.commodity) , :notice => '删除成功'
  end

  def image_set_master
    @operation = "image_set_master"
    
    if !params[:format].blank?
      import_file = ImportFile.find(params[:format].to_i)
      if !import_file.blank?
        @file_name = import_file.file_name
        @stamp.commodity.import_files.update_all is_master: false
        import_file.update is_master: true
      end
    end

    redirect_to image_index_import_files_path(@stamp.commodity) , :notice => '设置成功'
  end

  def to_batch_image_import
  end

  def batch_image_import
    @operation = "batch_image_import"
    zip_direct = "#{Rails.root}/public/pic/stamp/zip/"
    pic_direct = "/public/pic/stamp/"
    folder_name = []
    flash_message = "上传失败!"
    desc = ""
    
    unless request.get?
      if params[:file]['file'].original_filename.include?('.zip')
        if file_path = ImportFile.img_upload_path(params[:file]['file'], nil, "stamp")
          if (File.size(Rails.root.to_s + file_path)/1024/1024) <=  I18n.t("pic_upload_param.zip_size")
            if file = ImportFile.image_import(file_path, nil, current_user, "stamp")
              @file_name = file.file_name
              desc = ImportFile.decompress(file_path, zip_direct, pic_direct, current_user, "stamp")
              flash_message = "上传成功！"
              if !desc.blank?
                flash_message = "部分上传失败！"
                desc = "部分图片上传失败" + desc
                file.update desc: desc
              end
            end
          else
            flash_message = "上传文件的总大小应当不超过#{I18n.t("pic_upload_param.zip_size")}M"
          end
        end
      else
        flash_message = "请上传zip格式的压缩包"
      end
    end
    flash[:notice] = flash_message

    redirect_to stamps_path
  end

  private
    def set_stamp
      @stamp = Stamp.find(params[:id])
    end

    def stamp_params
      params[:stamp].permit(:serial_no, :format, :theme, :version, :designer, :ori_author, :engrave_author, :issue_at, :issue_unit, :print_unit, :gum, :circulation, :set_amount, :page_amount, :perforation, :specification, :editor, commodity_attributes: [:id, :no, :name, :short_name, :common_name, :catalog_id, :category, :is_show, :pic_name])
    end

    def upload_stamp(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/stamp/"
        if !File.exist?("#{Rails.root}/upload")
          Dir.mkdir("#{Rails.root}/upload")          
        end
        if !File.exist?("#{Rails.root}/upload/stamp/")
          Dir.mkdir("#{Rails.root}/upload/stamp/")          
        end
        filename = "#{Time.now.to_f}_#{file.original_filename}"
        file_ext = File.extname(filename)
        file_path = direct + filename
        relative_path = "/upload/stamp/" + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end

        size = File.size(file_path) 

        ImportFile.create! file_name: filename, file_path: relative_path, user_id: current_user.id, file_ext: file_ext, size: size

        file_path
      end
    end
end

