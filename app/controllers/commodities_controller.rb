class CommoditiesController < ApplicationController
  before_action :set_commodity, only: [:show, :edit, :update, :destroy]

  def index
    @commodities = Commodity.all
    respond_with(@commodities)
  end

  def show
    respond_with(@commodity)
  end

  def new
    @commodity = Commodity.new
    respond_with(@commodity)
  end

  def edit
  end

  def create
    @commodity = Commodity.new(commodity_params)
    @commodity.save
    respond_with(@commodity)
  end

  def update
    @commodity.update(commodity_params)
    respond_with(@commodity)
  end

  def destroy
    @commodity.destroy
    respond_with(@commodity)
  end

  private
    def set_commodity
      @commodity = Commodity.find(params[:id])
    end

    def commodity_params
      params[:commodity].permit(:commodity_no, :name, :short_name, :common_name, :catalog_id, :category, :is_show, :pic_name, import_file_attributes: [:id, :file_name, :file_path, :user_id, :size, :category, :file_ext])
    end
end
