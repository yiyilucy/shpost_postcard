class CommodityImportFileController < ApplicationController
  # load_and_authorize_resource
  user_logs_filter only: :download, symbol: :file_name, operation: :operation

  def index
    @import_files = nil
    @symbol_id = nil
    if !params[:commodity_id].blank?
      @symbol_id = params[:commodity_id].to_i
      @import_files = ImportFile.where(symbol_id: @symbol_id )
    end
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
    if !params[:id].blank? and !params[:commodity_id].blank?
      @import_file = ImportFile.find(params[:id].to_i)
      file_path = @import_file.file_path
      if File.exist?(file_path)
        File.delete(file_path)
      end
      @import_file.destroy
      
      respond_to do |format|
        format.html { redirect_to commodity_import_files_path(params[:commodity_id].to_i) }
        format.json { head :no_content }
      end
    end
  end

  

  private
    def set_import_file
      @import_file = ImportFile.find(params[:id])
    end

    def import_file_params
      params.require(:import_file).permit(:file_name, :file_path, :user_id, :symbol_id, :size, :category, :file_ext)
    end
end
