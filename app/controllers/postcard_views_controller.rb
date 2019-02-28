class PostcardViewsController < ApplicationController
  
  def index
    @banners = Banner.all
    #ImportFile.select(:file_path).where(symbol_type: 'banner').distinct.map{|x| x.file_path}
    render layout: false
  end

  def list_tab
    @stamp_catalogs = Catalog.where(catalog_type: 'stamp')

    @coin_catalogs = Catalog.where(catalog_type: 'coin')

    @bill_catalogs = Catalog.where(catalog_type: 'bill')
    
    
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
    # binding.pry
    @collections = Collection.where(front_user_id: current_front_user).order(created_at: :desc)
    @checked_fileds = []
    search_scope = params[:search_scope]
    result = nil

    # from serach
    if !params[:format].blank?
      if !(result = @collections.joins(:commodity).where("commodities.name like ? or commodities.common_name like ?", "%#{params[:format]}%", "%#{params[:format]}%")).blank?
        @collections = result
      end
    end

    # from filter
    stamp_collections = @collections.joins_stamp
    coin_collections = @collections.joins_coin
    bill_collections = @collections.joins_bill
    
    if params[:stamp_format] or params[:stamp_theme] or (!params[:format].blank? and result.blank?)
      if !params[:stamp_format].blank?
        @checked_fileds += params[:stamp_format]
        stamp_collections = stamp_collections.with_stamp_format(params[:stamp_format])
      end

      if !params[:stamp_theme].blank?
        @checked_fileds += params[:stamp_theme]
        stamp_collections = stamp_collections.with_stamp_theme(params[:stamp_theme])
      end

      if !params[:format].blank? and result.blank?
        stamp_collections = stamp_collections.with_stamp_serial_no(params[:format])
      end
    else 
      stamp_collections = []
    end

    if params[:coin_theme] or params[:coin_material] or params[:coin_weight] or params[:coin_year] or params[:coin_face_value] or params[:coin_pack_spec]
      if !params[:coin_theme].blank?
        @checked_fileds += params[:coin_theme]
        coin_collections = coin_collections.with_coin_theme(params[:coin_theme])
      end

      if !params[:coin_material].blank?
        @checked_fileds += params[:coin_material]
        coin_collections = coin_collections.with_coin_material(params[:coin_material])
      end

      if !params[:coin_weight].blank?
        @checked_fileds += params[:coin_weight]
        coin_collections = coin_collections.with_coin_weight(params[:coin_weight])
      end

      if !params[:coin_year].blank?
        @checked_fileds += params[:coin_year]
        coin_collections = coin_collections.with_coin_year(params[:coin_year])
      end

      if !params[:coin_face_value].blank?
        @checked_fileds += params[:coin_face_value]
         coin_collections = coin_collections.with_coin_face_value(params[:coin_face_value])
      end

      if !params[:coin_pack_spec].blank?
        @checked_fileds += params[:coin_pack_spec]
        coin_collections = coin_collections.with_coin_pack_spec(params[:coin_pack_spec])
      end
    else
      coin_collections = []
    end

    if params[:bill_version] or params[:bill_engrave_year] or params[:bill_face_value] or params[:bill_pack_spec] or params[:bill_prefix] or params[:bill_serial_no] or params[:bill_watermark]
      if !params[:bill_version].blank?
        @checked_fileds += params[:bill_version]
        bill_collections = bill_collections.with_bill_version(params[:bill_version])
      end

      if !params[:bill_engrave_year].blank?
        @checked_fileds += params[:bill_engrave_year]
        bill_collections = bill_collections.with_bill_engrave_year(params[:bill_engrave_year])
      end

      if !params[:bill_face_value].blank?
        @checked_fileds += params[:bill_face_value]
        bill_collections = bill_collections.with_bill_face_value(params[:bill_face_value])
      end

      if !params[:bill_pack_spec].blank?
        @checked_fileds += params[:bill_pack_spec]
        bill_collections = bill_collections.with_bill_pack_spec(params[:bill_pack_spec])
      end

      if !params[:bill_prefix].blank?
        @checked_fileds += params[:bill_prefix]
        bill_collections = bill_collections.with_bill_prefix(params[:bill_prefix])
      end

      if !params[:bill_serial_no].blank?
        @checked_fileds += params[:bill_serial_no]
        bill_collections = bill_collections.with_bill_serial_no(params[:bill_serial_no])
      end

      if !params[:bill_watermark].blank?
        @checked_fileds += params[:bill_watermark]
        bill_collections = bill_collections.with_bill_watermark(params[:bill_watermark])
      end
    else 
      bill_collections = []
    end

    if !stamp_collections.blank? and !coin_collections.blank? and !bill_collections.blank?
      @collections = stamp_collections + coin_collections + bill_collections      
    end

    @stamp_formats = DicTitle.find_by(category: "stamp", db_field: "format").blank? ? nil : DicTitle.find_by(category: "stamp", db_field: "format").dic_contents
    @stamp_themes = DicTitle.find_by(category: "stamp", db_field: "theme").blank? ? nil : DicTitle.find_by(category: "stamp", db_field: "theme").dic_contents
    @coin_themes = DicTitle.find_by(category: "coin", db_field: "theme").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "theme").dic_contents
    @coin_materials = DicTitle.find_by(category: "coin", db_field: "material").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "material").dic_contents
    @coin_weights = DicTitle.find_by(category: "coin", db_field: "weight").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "weight").dic_contents
    @coin_years = DicTitle.find_by(category: "coin", db_field: "year").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "year").dic_contents
    @coin_face_values = DicTitle.find_by(category: "coin", db_field: "face_value").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "face_value").dic_contents
    @coin_pack_specs = DicTitle.find_by(category: "coin", db_field: "pack_spec").blank? ? nil : DicTitle.find_by(category: "coin", db_field: "pack_spec").dic_contents
    @bill_versions = DicTitle.find_by(category: "bill", db_field: "version").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "version").dic_contents
    @bill_engrave_years = DicTitle.find_by(category: "bill", db_field: "engrave_year").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "engrave_year").dic_contents
    @bill_face_values = DicTitle.find_by(category: "bill", db_field: "face_value").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "face_value").dic_contents
    @bill_pack_specs = DicTitle.find_by(category: "bill", db_field: "pack_spec").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "pack_spec").dic_contents
    @bill_prefixs = DicTitle.find_by(category: "bill", db_field: "prefix").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "prefix").dic_contents
    @bill_serial_nos = DicTitle.find_by(category: "bill", db_field: "serial_no").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "serial_no").dic_contents
    @bill_watermarks = DicTitle.find_by(category: "bill", db_field: "watermark").blank? ? nil : DicTitle.find_by(category: "bill", db_field: "watermark").dic_contents
    render layout: false
  end

  # def sorting_collection
  #   render layout: false
  # end

  # def list_normal_collection
  #   render layout: false
  # end

  def follow
    @follows = Follow.where(front_user_id: current_front_user).order(created_at: :desc)
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

 
