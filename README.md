# DKImagePickerController-OC

<img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/2.jpeg" width="50%" height="50%"><img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/1.jpeg" width="50%" height="50%">
<img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/4.jpeg" width="50%" height="50%"><img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/3.jpeg" width="50%" height="50%">

参考[swift](https://github.com/zhangao0086/DKImagePickerController)

## Description
这是一个简单的图片选择器. 它使用了 [DKCamera][DKCamera] 来替代 `UIImagePickerController`.

### Features
* 支持单选和多选.
* 支持 iCloud.
* 支持自定义UI.
* 支持自定义 UICollectionViewLayout.

## Requirements
* iOS 8.0+
* ARC


## Getting Started
#### Initialization and presentation
```

DKImagePickerController * pickerController = [DKImagePickerController new];
[pickerController setDidSelectAssets:^(NSArray <DKAsset *>* assets){
  NSLog(@"%@", assets);
}];
[self presentViewController:pickerController animated:YES completion:nil];

````
