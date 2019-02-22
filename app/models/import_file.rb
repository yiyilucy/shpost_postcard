class ImportFile < ActiveRecord::Base
	belongs_to :user
	belongs_to :symbol, polymorphic: true

	CATEGORY = {stamp: '邮票', coin: '硬币', bill: '纸钞', banner: '横幅'}

	IS_MASTER = {true => '是',false => '否'}

	def self.img_upload_path(file, symbol, category)
		if !file.original_filename.empty?
			direct = "/public/pic/#{category}/"
			filename = "#{Time.now.to_i}_#{file.original_filename}"

	  	    if !File.exist?("#{Rails.root}/public/pic/")
	          Dir.mkdir("#{Rails.root}/public/pic/")          
	        end
	        if !File.exist?("#{Rails.root}/public/pic/#{category}/")
	          Dir.mkdir("#{Rails.root}/public/pic/#{category}/") 
	        end
		    if !symbol.blank?
		    	if !File.exist?("#{Rails.root}/public/pic/#{category}/#{symbol.id}/")
		          Dir.mkdir("#{Rails.root}/public/pic/#{category}/#{symbol.id}/") 
		        end
		    	direct = "#{direct}#{symbol.id}/"
		    else
		    	if !category.eql?"banner"
		    		if !File.exist?("#{Rails.root}/public/pic/#{category}/zip/")
			    		Dir.mkdir("#{Rails.root}/public/pic/#{category}/zip/") 
			    	end
			    	direct = "#{direct}zip/"
			    end
		    end

		    file_path = direct + filename
		    File.open(Rails.root.to_s + file_path, "wb") do |f|
		      f.write(file.read)
		    end
		    file_path
		end
	end

	def self.image_import(file_path, symbol, user, category)
		ori_file_name = File.basename(file_path)
		file_name = File.basename(file_path, "r:ISO-8859-1")
        file_ext = File.extname(file_name)
        size = File.size(Rails.root.to_s + file_path) 

        import_file = ImportFile.create! file_name: file_name, file_path: File.join(file_path.split(ori_file_name), file_name), user_id: user.id, file_ext: file_ext, size: size, symbol_id: symbol.blank? ? nil : symbol.id, category: category, symbol_type: symbol.blank? ? nil : symbol.class.to_s

        if symbol
        	if ImportFile.find_by(symbol_id: symbol.id, is_master: true).blank?
	        	ImportFile.where(symbol_id: symbol.id).order(:created_at).first.update is_master: true
	        end
         	ImageUtil.image_util(import_file)
        end

        return import_file
    end

	def image_destroy!
		file_path = Rails.root.to_s + self.file_path
		file_name = self.file_name
		extname = File.extname(file_name)
	  	base_name = File.basename(file_name, extname)
	  	big_name = File.join(base_name + "_big.jpg")
	  	small_name = File.join(base_name + "_small.jpg")
	  	base_path = file_path.split(file_name)
	  	big_path = File.join(base_path, big_name)
	  	small_path = File.join(base_path, small_name)

	    if File.exist?(file_path)
	      File.delete(file_path)
	    end
	    if File.exist?(big_path)
	      File.delete(big_path)
	    end
	    if File.exist?(small_path)
	      File.delete(small_path)
	    end
	    self.destroy!
	end

	def self.decompress(file_path, zip_direct, pic_direct, user, category)
		commodity_no = []
		desc = ""
		file_path = Rails.root.to_s + file_path
		
		Zip::File.open(file_path, "r:ISO-8859-1") do |zip|  
            zip.each do |folder| 
            	folder.extract(File.join(zip_direct,folder::name))  
                commodity_no << (folder::name).split('/')[0]
            end
            commodity_no.uniq.each do |f|
            	symbol = Commodity.find_by(no: f)
            	if !File.exist?("#{Rails.root}#{pic_direct}#{symbol.id}/")
					Dir.mkdir("#{Rails.root}#{pic_direct}#{symbol.id}/") 
				end
            	if !symbol.blank? and symbol.category.eql?category             
	                Dir.foreach(folder_direct = File.join(zip_direct,f)) do |pic|
	                	if pic !="." and pic !=".."
	                		if !(pic.include?('.jpg') or pic.include?('.jpeg') or pic.include?('.png') or pic.include?('.bmp'))
	                			desc += ",图片"+pic+"格式不正确"
	                			next
	                		end
	                		if (File.size(File.join(folder_direct,pic))/1024/1024) > I18n.t("pic_upload_param.pic_size")
	                			desc += ",图片"+pic+"大于#{I18n.t("pic_upload_param.pic_size")}M"
	                			next
	                		end	
		                    FileUtils.cp_r(File.join(folder_direct,pic), "#{Rails.root}#{pic_direct}#{symbol.id}/")
		                    new_pic_name = "#{Time.now.to_i}_#{pic}"
		                    File.rename("#{Rails.root}#{pic_direct}#{symbol.id}/#{pic}", "#{Rails.root}#{pic_direct}#{symbol.id}/#{new_pic_name}")
		                    self.image_import(File.join("#{pic_direct}#{symbol.id}/",new_pic_name), symbol, user, symbol.category)
		                end
	                end
	            else
	            	desc += ",文件夹"+f+"找不到对应商品大类的商品"
	            end
                FileUtils.rm_r(File.join(zip_direct,f))
            end
        end
        return desc
	end

	def img_relative_path(is_big)
		file_path = self.file_path
		start = file_path.index("/pic")
		relative_path = file_path[start, file_path.length-1]
		if is_big
			ext_index = relative_path.rindex(".")
			relative_path = relative_path[0, ext_index]+"_big.jpg"
		end

		return relative_path
	end

	def absolute_path
		self.file_path.blank? ? nil : Rails.root.to_s + self.file_path
	end

	
end
