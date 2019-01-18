class ImportFile < ActiveRecord::Base
	belongs_to :user
	belongs_to :symbol, polymorphic: true

	CATEGORY = {stamp: "邮票", coin: '硬币', bill: '纸钞'}

	def self.img_upload_path(file, object)
	    if !file.original_filename.empty?
	  	    direct = "#{Rails.root}/public/pic/#{object.category}/"
		    if !File.exist?("#{Rails.root}/public/pic/")
	          Dir.mkdir("#{Rails.root}/public/pic/")          
	        end
	        if !File.exist?("#{Rails.root}/public/pic/#{object.category}")
	          Dir.mkdir("#{Rails.root}/public/pic/#{object.category}") 
	        end
		    
		    filename = "#{object.id}_#{Time.now.to_f}_#{file.original_filename}"

		    file_path = direct + filename
		    File.open(file_path, "wb") do |f|
		      f.write(file.read)
		    end
		    file_path
		end
	end
end
