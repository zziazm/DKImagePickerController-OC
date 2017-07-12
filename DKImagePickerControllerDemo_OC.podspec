Pod::Spec.new do |s|
  s.name          = "DKImagePickerController_OC"
  s.version       = "0.0.1"
  s.summary       = "Image Picker Controller by OC."
  s.homepage      = "https://github.com/zziazm/DKImagePickerController-OC"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "1310726454@qq.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/zziazm/DKImagePickerController-OC.git", 
                     :tag => s.version.to_s }
  s.requires_arc  = true
end
