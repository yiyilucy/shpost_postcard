class ImportFilesController < ApplicationController
  load_and_authorize_resource
  user_logs_filter only: :download, symbol: :file_name, operation: :operation

  def index
    @import_files_grid = initialize_grid(@import_files,
         :order => 'import_files.created_at',
         :order_direction => 'desc')
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @import_file.save
        format.html { redirect_to @import_file, notice: I18n.t('controller.create_success_notice', model: '信息导入结果') }
        format.json { render action: 'show', status: :created, location: @import_file }
      else
        format.html { render action: 'new' }
        format.json { render json: @import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
  end

  def download
    @operation = "download"
    @file_name = ""
    file_path = @import_file.file_path
        
    if !file_path.blank? and File.exist?(file_path)
      io = File.open(file_path)
      filename_before = @import_file.file_path.split('/').last[0,@import_file.file_path.split('/').last.rindex('.')]
      filename_after = @import_file.file_path.split('.').last
      @file_name = filename_before + '.' + filename_after
      send_data(io.read, :type => "text/excel;charset=utf-8; header=present",              :filename => @file_name)
      io.close
    else
      redirect_to import_files_path, :notice => '文件不存在，下载失败！'
    end
  end

  private
    def set_import_file
      @import_file = ImportFile.find(params[:id])
    end

    def import_file_params
      params.require(:import_file).permit(:file_name, :file_path)
    end
end
