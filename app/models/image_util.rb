class ImageUtil 
  def self.image_util(import_file)
  	big_size_width = I18n.t("image_util_param.big_size_width")
  	big_size_height = I18n.t("image_util_param.big_size_height")
    small_size_width = I18n.t("image_util_param.small_size_width")
    small_size_height = I18n.t("image_util_param.small_size_height")
    file_path = import_file.file_path
    file_name = import_file.file_name
  	image = MiniMagick::Image.open(file_path)
  	w,d = image[:width], image[:height]
  	if w > big_size_width || d > big_size_height
  		image.resize I18n.t("image_util_param.image_resize_big")
  		image.quality I18n.t("image_util_param.image_quality")
  	end
  	extname = File.extname(file_name)
  	new_name = File.basename(file_name, extname)
  	image_name = File.join("#{new_name}_big.jpg")
  	image_path = file_path.split(file_name)
  	image_new_path = File.join(image_path, image_name)
    image.write (image_new_path)
  	if w > small_size_width || d > small_size_height
  		image.resize I18n.t("image_util_param.image_resize_small")
  		image.quality I18n.t("image_util_param.image_quality")
  	end
  	image_name = File.join("#{new_name}_small.jpg")
  	image_new_path = File.join(image_path, image_name)
    image.write (image_new_path)
  end
end
