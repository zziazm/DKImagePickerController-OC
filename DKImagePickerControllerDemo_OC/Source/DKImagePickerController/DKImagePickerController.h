//
//  DKImagePickerViewController.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DKAsset;
@class DKImagePickerController;
@class DKAssetGroupDetailBaseCell;
@protocol DKImagePickerControllerUIDelegate <NSObject>



- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc;


@optional

- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       showsCancelButtonForVC:(UIViewController *)vc;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       hidesCancelButtonForVC:(UIViewController *)vc;

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didSelectAssets:(NSArray <DKAsset *> *)didSelectAssets;
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didDeselectAssets:(NSArray <DKAsset *> *)didDeselectAssets;
- (void)imagePickerControllerDidReachMaxLimit:(DKImagePickerController *)imagePickerController;
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController;

- (UIColor *)imagePickerControllerCollectionViewBackgroundColor;

- (DKAssetGroupDetailBaseCell *)imagePickerControllerCollectionImageCell;
- (DKAssetGroupDetailBaseCell *)imagePickerControllerCollectionCameraCell;
- (DKAssetGroupDetailBaseCell *)imagePickerControllerCollectionVideoCell;

@end

typedef enum : NSUInteger {
    DKImagePickerControllerAssetAllPhotosType,
    DKImagePickerControllerAssetAllVideosType,
    DKImagePickerControllerAssetAllAssetsType,
} DKImagePickerControllerAssetType;


typedef enum : NSUInteger {
    DKImagePickerControllerSourceCameraType,
    DKImagePickerControllerSourcePhotoType,
    DKImagePickerControllerSourceBothType,
} DKImagePickerControllerSourceType;

@interface DKImagePickerController : UINavigationController

@end
