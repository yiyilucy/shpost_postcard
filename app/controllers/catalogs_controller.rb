class CatalogsController < ApplicationController
  # before_action :set_product_catalog, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  def index
    # @product_catalogs = ProductCatalog.all
    # respond_with(@product_catalogs)
   @catalogs_grid = initialize_grid(@catalogs)
  end

  def show
    # respond_with(@product_catalog)
  end

  def new
    # @product_catalog = ProductCatalog.new
    # respond_with(@product_catalog)
  end

  def edit
  end

  def create
    # @product_catalog = ProductCatalog.new(product_catalog_params)
    # @product_catalog.save
    # respond_with(@product_catalog)
    respond_to do |format|
      if @catalog.save
        format.html { redirect_to @catalog, notice: I18n.t('controller.create_success_notice', model: '商品目录') }
        format.json { render action: 'show', status: :created, location: @catalog }
      else
        format.html { render action: 'new' }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # @product_catalog.update(product_catalog_params)
    # respond_with(@product_catalog)
    respond_to do |format|
      if @catalog.update(catalog_params)
        format.html { redirect_to @catalog, notice: I18n.t('controller.update_success_notice', model: '商品目录') }
        format.json { render action: 'show', status: :created, location: @catalog }
      else
        format.html { render action: 'edit' }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # @product_catalog.destroy
    # respond_with(@product_catalog)
    @catalog.destroy
    respond_to do |format|
      format.html { redirect_to catalogs_url }
      format.json { head :no_content }
    end
  end

  private
    # def set_product_catalog
    #   @product_catalog = ProductCatalog.find(params[:id])
    # end

    def catalog_params
      params[:catalog].permit(:catalog_no, :catalog_name, :catalog_type, :is_show)
    end
  end
