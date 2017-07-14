# DKImagePickerController-OC

<img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/1.png" width="50%" height="50%"><img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/2.png" width="50%" height="50%">
<img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/3.png" width="50%" height="50%"><img src="https://github.com/zziazm/DKImagePickerController-OC/blob/master/4.png" width="50%" height="50%">

参考[swift](https://github.com/zhangao0086/DKImagePickerController)写了oc的

## Description
It's a Facebook style Image Picker Controller by Swift. It uses [DKCamera][DKCamera] instead of `UIImagePickerController`.

### Features
* Supports both single and multiple selection.
* Supports filtering albums and sorting by type.
* Supports landscape and iPad and orientation switching.
* Supports iCloud.
* Supports UIAppearance.
* Customizable camera.
* Customizable UI.
* Customizable UICollectionViewLayout.
* Supports footer view.

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
