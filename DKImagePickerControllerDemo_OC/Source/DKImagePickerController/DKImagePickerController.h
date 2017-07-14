//
//  DKImagePickerViewController.h
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class DKAsset;
@class DKImagePickerController;
@class DKAssetGroupDetailBaseCell;
@class DKImagePickerControllerDefaultUIDelegate;

@protocol DKImagePickerControllerCameraProtocol <NSObject>

- (void)setDidCancel:(void(^)())block;
- (void)setDidFinishCapturingImage:(void(^)(UIImage * image))block;
- (void)setDidFinishCapturingVideo:(void(^)(NSURL * videoURL))videoURL;

@end



@protocol DKImagePickerControllerUIDelegate <NSObject>


/**
 The picker calls -prepareLayout once at its first layout as the first message to the UIDelegate instance.
 */
- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc;

/**
 Returns a custom camera.

 @return The returned UIViewControlelr must conform to the DKImagePickerControllerCameraProtocol
 
 */
- (UIViewController <DKImagePickerControllerCameraProtocol> *)imagePickerControllerCreateCamera:(DKImagePickerController *)imagePickerController;


/**
 The layout is to provide information about the position and visual state of items in the collection view.
 */
- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController;

/**
 Called when the user needs to show the cancel button.
 */
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       showsCancelButtonForVC:(UIViewController *)vc;

/**
 Called when the user needs to hide the cancel button.
 */
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       hidesCancelButtonForVC:(UIViewController *)vc;

/**
 Called after the user changes the selection.
 */
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didSelectAssets:(NSArray <DKAsset *> *)didSelectAssets;
/**
 Called after the user changes the selection.
 */



- (void)imagePickerController:(DKImagePickerController *)imagePickerController
            didDeselectAssets:(NSArray <DKAsset *> *)didDeselectAssets;

/**
 Called when the count of the selectedAssets did reach `maxSelectableCount`.
 */
- (void)imagePickerControllerDidReachMaxLimit:(DKImagePickerController *)imagePickerController;

/**
 Accessory view below content. default is nil.
 */
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController;

/**
 Set the color of the background of the collection view.
 */
- (UIColor *)imagePickerControllerCollectionViewBackgroundColor;


/**
 Set the custom cell of the collection view.


 @return subClass of DKAssetGroupDetailBaseCell
 */
- (Class)imagePickerControllerCollectionImageCell;
- (Class)imagePickerControllerCollectionCameraCell;
- (Class)imagePickerControllerCollectionVideoCell;
@end

typedef enum : NSUInteger {
    DKImagePickerControllerAssetAllPhotosType,//Get all photos assets in the assets group.
    DKImagePickerControllerAssetAllVideosType,//Get all video assets in the assets group.
    DKImagePickerControllerAssetAllAssetsType,//Get all assets in the group.
} DKImagePickerControllerAssetType;


typedef enum : NSUInteger {
    DKImagePickerControllerSourceCameraType,
    DKImagePickerControllerSourcePhotoType,
    DKImagePickerControllerSourceBothType,
} DKImagePickerControllerSourceType;

@interface DKImagePickerController : UINavigationController
@property (nonatomic, strong) DKImagePickerControllerDefaultUIDelegate * UIDelegate;

///Forces deselect of previous selected image.Default value is NO.
@property (nonatomic, assign) BOOL singleSelect;

///Auto close picker on single select.Default value is YES.
@property (nonatomic, assign) BOOL autoCloseOnSingleSelect;

///The maximum count of assets which the user will be able to select.
@property (nonatomic, assign) NSInteger maxSelectableCount;

/// Set the defaultAssetGroup to specify which album is the default asset group.
@property (nonatomic, assign) PHAssetCollectionSubtype defaultAssetGroup;
/**
 The types of PHAssetCollection to display in the picker.
 Default value is @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
 @(PHAssetCollectionSubtypeSmartAlbumFavorites),
 @(PHAssetCollectionSubtypeAlbumRegular)]
 */
@property (nonatomic, copy)NSArray <NSNumber *> * assetGroupTypes;

/// Set the showsEmptyAlbums to specify whether or not the empty albums is shown in the picker.Default value is YES.
@property (nonatomic, assign) BOOL showsEmptyAlbums;

@property (nonatomic, copy) BOOL (^assetFilter) (PHAsset * asset);

/// The type of picker interface to be displayed by the controller.
@property (nonatomic, assign) DKImagePickerControllerAssetType assetType;


/// The predicate applies to images only.
@property (nonatomic, strong) NSPredicate * imageFetchPredicate;

/// The predicate applies to videos only.
@property (nonatomic, strong) NSPredicate * videoFetchPredicate;

/// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.Default value is DKImagePickerControllerSourceBothType
@property (nonatomic, assign) DKImagePickerControllerSourceType sourceType;

/// Whether allows to select photos and videos at the same time.Default value is YES.
@property (nonatomic, assign) BOOL allowMultipleTypes;

/// If YES, and the requested image is not stored on the local device, the Picker downloads the image from iCloud.Default value is YES.
@property (nonatomic, assign) BOOL autoDownloadWhenAssetIsInCloud;

/// Determines whether or not the rotation is enabled.Default value is NO.
@property (nonatomic, assign) BOOL allowsLandscape;

/// The callback block is executed when user pressed the cancel button.
@property (nonatomic, copy) void(^didCancel)();

/// The callback block is executed when user pressed the select button.
@property (nonatomic, copy) void(^didSelectAssets)(NSArray<DKAsset *> * asset);

/// It will have selected the specific assets.
@property (nonatomic, copy) NSArray  <DKAsset *> * defaultSelectedAssets;

@property (nonatomic, strong) NSMutableArray <DKAsset *> *selectedAssets;

///Default value is NO.
@property (nonatomic, assign) BOOL showsCancelButton;

- (void)selectImage:(DKAsset *)asset;
- (void)deselectImage:(DKAsset *)asset;
- (void)presentCamera;

- (void)done;
- (void)dismiss;


@end
