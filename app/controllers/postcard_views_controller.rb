class PostcardViewsController < ApplicationController
  
  def index
    @banners = Banner.all
    #ImportFile.select(:file_path).where(symbol_type: 'banner').distinct.map{|x| x.file_path}
    render layout: false
  end

  def list_tab
    @stamp_catalogs = Catalog.select(:catalog_name).where(catalog_type: 'stamp').distinct.map{|x| x.catalog_name}

    @coin_catalogs = Catalog.select(:catalog_name).where(catalog_type: 'coin').distinct.map{|x| x.catalog_name}

    @bill_catalogs = Catalog.select(:catalog_name).where(catalog_type: 'bill').distinct.map{|x| x.catalog_name}
    
    render layout: false
  end

  # def list_normal
  #   render layout: false
  # end

  # def product
  #   render layout: false
  # end

  def appraisal
    render layout: false
  end

  def news
    render layout: false
  end

  def value
    render layout: false
  end

  # def sorting_edit
  #   render layout: false
  # end

  def sorting
    render layout: false
  end

  # def sorting_collection
  #   render layout: false
  # end

  # def list_normal_collection
  #   render layout: false
  # end

  def follow
    render layout: false
  end

  def product_follow
    render layout: false
  end

  # def product_sorting
  #   render layout: false
  # end
  

  
  def create
    # @product_catalog = ProductCatalog.new(product_catalog_params)
    # @product_catalog.save
    # respond_with(@product_catalog)
    
  end

  def update
    # @product_catalog.update(product_catalog_params)
    # respond_with(@product_catalog)
    
  end

  def destroy
    # @product_catalog.destroy
    # respond_with(@product_catalog)
   
  end
end

 
