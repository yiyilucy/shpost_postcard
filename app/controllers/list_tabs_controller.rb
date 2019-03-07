class ListTabsController < ApplicationController
 
  def index
    render layout: false
  end

  def product
    render layout: false
  end

  def list_normal
    if !params[:is_tabs].blank? and params[:is_tabs].eql?"true"
      @commodities= Commodity.where(catalog_id:params[:format].to_i)
    	
      @catalogs = Catalog.find(params[:format].to_i)
      @checked_fileds = [] 
    else
      @list_normals = Commodity.all
      @checked_fileds = []
      result = nil
      search_scope = params[:search_scope]

    # from serach

      if !params[:name].blank?
        list_normals_with_name =Commodity.where("name like ? or short_name like ? or common_name like ?", "%#{params[:name]}%", "%#{params[:name]}%", "%#{params[:name]}%")

        @stamp_list_normals =Commodity.joins_stamp.where("name like ? or short_name like ? or common_name like ? or stamps.serial_no like ?", "%#{params[:name]}%", "%#{params[:name]}%", "%#{params[:name]}%", "%#{params[:name]}%")

        @coin_list_normals = list_normals_with_name.joins_coin

        @bill_list_normals = list_normals_with_name.joins_bill
      else
        @stamp_list_normals = @list_normals.joins_stamp
        @coin_list_normals = @list_normals.joins_coin
        @bill_list_normals = @list_normals.joins_bill
      end

    # from filter
      if !search_scope.eql?"all"
        if !params[:stamp_format].blank? or !params[:stamp_theme].blank? or !params[:coin_theme].blank? or !params[:coin_material].blank? or !params[:coin_weight].blank? or !params[:coin_year].blank? or !params[:coin_face_value].blank? or !params[:coin_pack_spec].blank? or !params[:bill_version].blank? or !params[:bill_engrave_year].blank? or !params[:bill_face_value].blank? or !params[:bill_pack_spec].blank? or !params[:bill_prefix].blank? or !params[:bill_serial_no].blank? or !params[:bill_watermark].blank?
          if !params[:stamp_format].blank? or !params[:stamp_theme].blank?
            if !params[:stamp_format].blank?
              @checked_fileds += params[:stamp_format]
              @stamp_list_normals = @stamp_list_normals.with_stamp_format(params[:stamp_format]) if ! @stamp_list_normals.blank?
            end

            if !params[:stamp_theme].blank?
              @checked_fileds += params[:stamp_theme]
              @stamp_list_normals = @stamp_list_normals.with_stamp_theme(params[:stamp_theme]) if ! @stamp_list_normals.blank?
            end
          else
            @stamp_list_normals = []
          end
          
          if !params[:coin_theme].blank? or !params[:coin_material].blank? or !params[:coin_weight].blank? or !params[:coin_year].blank? or !params[:coin_face_value].blank? or !params[:coin_pack_spec].blank?
            if !params[:coin_theme].blank?
              @checked_fileds += params[:coin_theme]
              @coin_list_normals = @coin_list_normals.with_coin_theme(params[:coin_theme]) if ! @coin_list_normals.blank?
            end

            if !params[:coin_material].blank?
              @checked_fileds += params[:coin_material]
              @coin_list_normals = @coin_list_normals.with_coin_material(params[:coin_material]) if ! @coin_list_normals.blank?
            end

            if !params[:coin_weight].blank?
              @checked_fileds += params[:coin_weight]
              @coin_list_normals = @coin_list_normals.with_coin_weight(params[:coin_weight]) if ! @coin_list_normals.blank?
            end

            if !params[:coin_year].blank?
              @checked_fileds += params[:coin_year]
              @coin_list_normals = @coin_list_normals.with_coin_year(params[:coin_year]) if ! @coin_list_normals.blank?
            end

            if !params[:coin_face_value].blank?
              @checked_fileds += params[:coin_face_value]
               @coin_list_normals = @coin_list_normals.with_coin_face_value(params[:coin_face_value]) if ! @coin_list_normals.blank?
            end

            if !params[:coin_pack_spec].blank?
              @checked_fileds += params[:coin_pack_spec]
              @coin_collections = @coin_list_normals.with_coin_pack_spec(params[:coin_pack_spec]) if ! @coin_list_normals.blank?
            end
          else
            @coin_list_normals = []
          end
       
          if !params[:bill_version].blank? or !params[:bill_engrave_year].blank? or !params[:bill_face_value].blank? or !params[:bill_pack_spec].blank? or !params[:bill_prefix].blank? or !params[:bill_serial_no].blank? or !params[:bill_watermark].blank?
            if !params[:bill_version].blank?
              @checked_fileds += params[:bill_version]
              @bill_list_normals = @bill_list_normals.with_bill_version(params[:bill_version]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_engrave_year].blank?
              @checked_fileds += params[:bill_engrave_year]
              @bill_list_normals = @bill_list_normals.with_bill_engrave_year(params[:bill_engrave_year]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_face_value].blank?
              @checked_fileds += params[:bill_face_value]
              @bill_list_normals = @bill_list_normals.with_bill_face_value(params[:bill_face_value]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_pack_spec].blank?
              @checked_fileds += params[:bill_pack_spec]
              @bill_list_normals = @bill_list_normals.with_bill_pack_spec(params[:bill_pack_spec]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_prefix].blank?
              @checked_fileds += params[:bill_prefix]
              @bill_list_normals = @bill_list_normals.with_bill_prefix(params[:bill_prefix]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_serial_no].blank?
              @checked_fileds += params[:bill_serial_no]
              @bill_list_normals = @bill_list_normals.with_bill_serial_no(params[:bill_serial_no]) if ! @bill_list_normals.blank?
            end

            if !params[:bill_watermark].blank?
              @checked_fileds += params[:bill_watermark]
              @bill_list_normals = @bill_list_normals.with_bill_watermark(params[:bill_watermark]) if ! @bill_list_normals.blank?
            end
          else
            @bill_list_normals = []
          end
        end
      end
      
      if !@stamp_list_normals.blank? or !@coin_list_normals.blank? or !@bill_list_normals.blank?
        @commodities = @stamp_list_normals + @coin_list_normals + @bill_list_normals      
      else
        @commodities = []
      end
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
end
