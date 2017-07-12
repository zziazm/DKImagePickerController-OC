Pod::Spec.new do |s| 
  s.name         = "DKImagePickrControllerDemo_OC" 
  s.version      = "0.0.1" 
  s.summary      = "图片选择器"
  s.description  = <<-DESC
                  简单的图片选择器
                   DESC
  s.homepage     = "https://github.com/zziazm/DKImagePickerController-OC" 
  s.license      = "MIT" 
  s.author       = { "zziazm" => "1310726454@qq.com" } 
  s.platform     = :ios, "8.0" 
  s.source       = { :git => "https://github.com/zziazm/DKImagePickerController-OC.git", :tag => s.version }
  s.source_files = "DKImagePickerControllerDemo_OC/**/*.{h,m}" 
  s.requires_arc = true 
end
