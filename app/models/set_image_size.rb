class SetImageSize < ActiveRecord::Base
  def self.set_image_size(import_file)
  	big_size = [640, 410]
    small_size = [320, 205]
    file_path = import_file.file_path
    file_name = import_file.file_name
  	image = MiniMagick::Image.open(file_path)
  	w,d = image[:width], image[:height]
  	unless w < big_size[0] && d < big_size[1]
  		image.resize "640x410"
  		image.quality "75%"
  	end
  	extname = File.extname(file_name)
  	new_name = File.basename(file_name, extname)
  	image_name = File.join(new_name + "_big.jpg")
  	image_path = file_path.split(file_name)
  	image_new_path = File.join(image_path, image_name)
    image.write (image_new_path)
  	unless w < small_size[0] && d < small_size[1]
  		image.resize "320x205"
  		image.quality "75%"
  	end
  	extname = File.extname(file_name)
  	new_name = File.basename(file_name, extname)
  	image_name = File.join(new_name + "_small.jpg")
  	image_path = file_path.split(file_name)
  	image_new_path = File.join(image_path, image_name)
    image.write (image_new_path)
  end
end
# big_size = [640, 410]
# small_size = [320, 205]
# file_path = "/home/gaohelie/1.jpg"
# file_name = "1.jpg"
# image = MiniMagick::Image.open(file_path)
# w,d = image[:width], image[:height]
# unless w < big_size[0] && d < big_size[1]
# 	image.resize "640x410"
# 	image.quality "75%"
# end
# extname = File.extname(file_name)
# new_name = File.basename(file_name, extname)
# image_name = File.join(new_name + "_big.jpg")
# image_path = file_path.split(file_name)
# image_new_path = File.join(image_path, image_name)
# image.write (image_new_path)
# unless w < small_size[0] && d < small_size[1]
# 	image.resize "320x205"
# 	image.quality "75%"
# end
# extname = File.extname(file_name)
# new_name = File.basename(file_name, extname)
# image_name = File.join(new_name + "_small.jpg")
# image_path = file_path.split(file_name)
# image_new_path = File.join(image_path, image_name)
# image.write (image_new_path)
