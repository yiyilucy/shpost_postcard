class DicContentsController < ApplicationController
  load_and_authorize_resource :dic_content
  user_logs_filter only: [:create, :update, :destroy], operation: :operation, symbol: :name

  def index
    @dic_contents = nil
    @dic_title_id = nil
    if !params[:dic_title_id].blank?
      @dic_title_id = params[:dic_title_id].to_i
      @dic_contents = DicContent.where(dic_title_id: @dic_title_id )
    end
    @dic_contents_grid = initialize_grid(@dic_contents) 
  end

  def show
  end

  def new
    @dic_title_id = params[:dic_title_id].blank? ? nil : params[:dic_title_id].to_i
  end

  def edit
    @edit = true
  end

  def create
    @operation = "create"
    dic_title_id = params[:dic_title_id].blank? ? nil : params[:dic_title_id].to_i
    respond_to do |format|
      if !dic_title_id.blank?
        @dic_content.dic_title_id = dic_title_id
        if @dic_content.save
          format.html { redirect_to "/dic_titles/#{dic_title_id}/dic_contents", notice: I18n.t('controller.create_success_notice', model: '字典内容') }
          format.json { head :no_content }
        else
          format.html { redirect_to "/dic_contents/new?dic_title_id=#{dic_title_id}" }
          format.json { render json: @dic_content.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @operation = "update"
    respond_to do |format|
      if @dic_content.update(dic_content_params)
        format.html { redirect_to "/dic_titles/#{@dic_content.dic_title_id}/dic_contents", notice: I18n.t('controller.update_success_notice', model: '字典内容')}
        format.json { head :no_content }
      else
        format.html { redirect_to "/dic_contents/edit?dic_title_id=#{@dic_content.dic_title_id}" }
        format.json { render json: @dic_content.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @operation = "destroy"
    dic_title_id = params[:dic_title_id].blank? ? nil : params[:dic_title_id].to_i
    @dic_content.destroy
    respond_to do |format|
      format.html { redirect_to "/dic_titles/#{@dic_content.dic_title_id}/dic_contents" }
      format.json { head :no_content }
    end
  end

  private
    def set_dic_content
      @dic_content = DicContent.find(params[:id])
    end

    def dic_content_params
      params.require(:dic_content).permit(:name, :dic_title_id, :is_show, :order)
    end
end
