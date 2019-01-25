class ImportFile < ActiveRecord::Base
	belongs_to :user
	belongs_to :symbol, polymorphic: true

	CATEGORY = {stamp: "邮票", coin: '硬币', bill: '纸钞'}

	IS_MASTER = {true => '是',false => '否'}

	def self.img_upload_path(file, symbol, category)
		if !file.original_filename.empty?
	  	    if !File.exist?("#{Rails.root}/public/pic/")
	          Dir.mkdir("#{Rails.root}/public/pic/")          
	        end
	        if !File.exist?("#{Rails.root}/public/pic/#{category}/")
	          Dir.mkdir("#{Rails.root}/public/pic/#{category}/") 
	        end
		    if !symbol.blank?
		    	direct = "#{Rails.root}/public/pic/#{category}/"
		    	filename = "#{symbol.id}_#{Time.now.to_f}_#{file.original_filename}"
		    else
		    	if !File.exist?("#{Rails.root}/public/pic/#{category}/zip/")
		    		Dir.mkdir("#{Rails.root}/public/pic/#{category}/zip/") 
		    	end
		    	direct = "#{Rails.root}/public/pic/#{category}/zip/"
		    	filename = "#{Time.now.to_f}_#{file.original_filename}"
		    end

		    file_path = direct + filename
		    File.open(file_path, "wb") do |f|
		      f.write(file.read)
		    end
		    file_path
		end
	end

	def self.image_import(file_path, symbol, user, category)
		file_name = File.basename(file_path)
        file_ext = File.extname(file_name)
        size = File.size(file_path) 

        import_file = ImportFile.create! file_name: file_name, file_path: file_path, user_id: user.id, file_ext: file_ext, size: size, symbol_id: symbol.blank? ? nil : symbol.id, category: category, symbol_type: symbol.blank? ? nil : symbol.class.to_s

        if symbol
         	SetImageSize.set_image_size(import_file)
        end

        return import_file
    end

	def self.image_destroy(import_file)
		file_path = import_file.file_path
		file_name = import_file.file_name
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
	    import_file.destroy
	end

	def self.decompress(file_path, zip_direct, pic_direct, user, category)
		commodity_no = []
		desc = ""
		
		Zip::File.open(file_path) do |zip|  
            zip.each do |folder| 
            	folder.extract(File.join(zip_direct,folder::name))  
                commodity_no << (folder::name).split('/')[0]
            end
            commodity_no.uniq.each do |f|
            	symbol = Commodity.find_by(no: f)
            	if !symbol.blank? and symbol.category.eql?category             
	                Dir.foreach(folder_direct = File.join(zip_direct,f)) do |pic|
	                	if pic !="." and pic !=".."
	                		if !(pic.include?('.jpg') or pic.include?('.jpeg') or pic.include?('.png') or pic.include?('.bmp'))
	                			desc += ",图片"+pic+"格式不正确"
	                			next
	                		end
	                		if (File.size(File.join(folder_direct,pic))/1024/1024) > I18n.t("pic_size")
	                			desc += ",图片"+pic+"大于#{I18n.t("pic_size")}M"
	                			next
	                		end	
		                    FileUtils.cp_r(File.join(folder_direct,pic), pic_direct)
		                    new_pic_name = "#{symbol.id}_#{Time.now.to_f}_#{pic}"
		                    File.rename("#{pic_direct}#{pic}", "#{pic_direct}#{new_pic_name}")
		                    self.image_import(File.join(pic_direct,new_pic_name), symbol, user, symbol.category)
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

	
end
