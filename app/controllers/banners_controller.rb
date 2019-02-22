class BannersController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: [:do_create, :do_update, :destroy], symbol: :title, object: :banner, operation: :operation

  def index
    @banners_grid = initialize_grid(@banners,
         :order => 'banners.order',
         :order_direction => 'asc') 
  end

  def show
  end

  def new
  end

  def edit
    @banner
  end

  def create
    @operation = "create"

    respond_to do |format|
      if @banner.save
        format.html { redirect_to @banner, notice: I18n.t('controller.create_success_notice', model: '横幅管理') }
        format.json { render action: 'show', status: :created, location: @banner }
      else
        format.html { render action: 'new' }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  def do_create
    if !params[:file].blank? and !params[:file][:file].blank?
      if Banner.count < 5
        @operation = "create"
        
        @title = params[:title]
        link = params[:link]
        order = params[:order].blank? ? nil : params[:order].to_i
        is_show = (params[:is_show].blank?) ? false : true

        if params[:file]['file'].original_filename.include?('.jpg') or params[:file]['file'].original_filename.include?('.jpeg') or params[:file]['file'].original_filename.include?('.png') or params[:file]['file'].original_filename.include?('.bmp')
          if file_path = ImportFile.img_upload_path(params[:file]['file'], nil, "banner")
            if (File.size(Rails.root.to_s + file_path)/1024/1024) <= I18n.t("pic_upload_param.pic_size")
              if file = ImportFile.image_import(file_path, nil, current_user, "banner")
                pic_name = file.file_name
                if banner = Banner.create!(title: @title, link: link, order: order, is_show: is_show, pic_name: pic_name)
                  file.update symbol_id: banner.id, symbol_type: banner.class.to_s
                  redirect_to banners_url, :notice => I18n.t('controller.create_success_notice', model: '横幅管理')
                else
                  flash[:alert] = @banner.errors
                  render action: 'new'
                end
              end
            else
              flash[:alert] = "图片大小应小于#{I18n.t("pic_upload_param.pic_size")}M"
              render action: 'new'
            end
          end
        else
          flash[:alert] = "请上传jpg, jpeg, png, bmp格式图片"
          render action: 'new'
        end
      else
        flash[:alert] = "横幅管理最多只允许5条条目，请删除原有条目后再新增"
        render action: 'new'
      end
    else
      flash[:alert] = "请上传图片"
      render action: 'new'
    end
  end

  def update
    @operation = "update"
    respond_to do |format|
      if @banner.update(banner_params)
        format.html { redirect_to @banner, notice: I18n.t('controller.update_success_notice', model: '横幅管理')}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end

  def do_update
    @operation = "update"
    @banner = params[:symbol_id].blank? ? nil : Banner.find(params[:symbol_id].to_i)    
    @title = params[:title]
    @banner.title = @title
    @banner.link = params[:link]
    @banner.order = params[:order].blank? ? nil : params[:order].to_i
    @banner.is_show = (params[:is_show].blank?) ? false : true

    if !params[:file].blank? and !params[:file][:file].blank?
      if params[:file]['file'].original_filename.include?('.jpg') or params[:file]['file'].original_filename.include?('.jpeg') or params[:file]['file'].original_filename.include?('.png') or params[:file]['file'].original_filename.include?('.bmp')
        if file_path = ImportFile.img_upload_path(params[:file]['file'], nil, "banner")
          if (File.size(Rails.root.to_s + file_path)/1024/1024) <= I18n.t("pic_upload_param.pic_size")
            @banner.import_file.image_destroy!
            if file = ImportFile.image_import(file_path, nil, current_user, "banner")
              @banner.pic_name = file.file_name
              file.update symbol_id: @banner.id, symbol_type: @banner.class.to_s
            end
          else
            flash[:alert] = "图片大小应小于#{I18n.t("pic_upload_param.pic_size")}M"
            render action: 'edit'
          end
        end
      else
        flash[:alert] = "请上传jpg, jpeg, png, bmp格式图片"
        render action: 'edit'
      end
    end
    if @banner.save
      redirect_to banners_url, :notice => I18n.t('controller.update_success_notice', model: '横幅管理')
    else
      flash[:alert] = @banner.errors
      render action: 'edit'
    end
  end

  def destroy
    @operation = "destroy"
    @title = @banner.title
    @banner.import_file.image_destroy! 
    @banner.destroy
    respond_to do |format|
      format.html { redirect_to banners_url }
      format.json { head :no_content }
    end
  end

  private
    def set_banner
      @banner = Banner.find(params[:id])
    end

    def banner_params
      params.require(:banner).permit(:title, :link, :is_show, :order, :pic_name)
    end
end
