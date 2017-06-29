//
//  DKImagePickerViewController.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerController.h"
#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKImageManager.h"
#import "DKAssetGroupDetailVC.h"
#import "DKGroupDataManager.h"
@interface DKImagePickerController ()
@property (nonatomic, assign) BOOL hasInitialized;
@property (nonatomic, strong) PHFetchOptions * assetFetchOptions;
@end

@implementation DKImagePickerController
- (void)done{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_hasInitialized) {
        _hasInitialized = YES;
        if (self.sourceType == DKImagePickerControllerSourceCameraType) {
            
        }else{
            self.navigationBarHidden = NO;
            DKAssetGroupDetailVC * vc = [[DKAssetGroupDetailVC alloc] init];
            vc.imagePickerController = self;
            [self.UIDelegate prepareLayout:self vc:vc];
            [self updateCancelButtonForVC:vc];
            self.viewControllers = @[vc];
            if (self.defaultSelectedAssets.count > 0) {
                [self.UIDelegate imagePickerController:self didSelectAssets:self.defaultSelectedAssets];
            }
        }
    }
}

- (void)updateCancelButtonForVC:(UIViewController *)vc{
    if (self.showsCancelButton) {
        [self.UIDelegate imagePickerController:self showsCancelButtonForVC:vc];
    }else{
        [self.UIDelegate imagePickerController:self hidesCancelButtonForVC:vc];
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton{
    if (_showsCancelButton != showsCancelButton) {
        _showsCancelButton = showsCancelButton;
        UIViewController * vc = [[self viewControllers] firstObject];
        [self updateCancelButtonForVC:vc];
    }
}
- (id)init{
    if (self = [super init]) {
        _showsCancelButton = NO;
        _sourceType = DKImagePickerControllerSourceBothType;
        _hasInitialized = false;
        _singleSelect = NO;
        _maxSelectableCount = 999;
        self.assetGroupTypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                              @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                              @(PHAssetCollectionSubtypeAlbumRegular)];
        self.showsEmptyAlbums = YES;
        self.assetType = DKImagePickerControllerAssetAllAssetsType;
        _allowMultipleTypes = NO;
        self.autoDownloadWhenAssetIsInCloud = YES;
        _allowsLandscape = NO;
        _selectedAssets = @[].mutableCopy;
        
        UIViewController * rootVC = [UIViewController new];
        self.viewControllers = @[rootVC];
        self.preferredContentSize = CGSizeMake(680, 600);
        rootVC.navigationItem.hidesBackButton = YES;
        
        
    }
    return self;
}
- (PHFetchOptions *)assetFetchOptions{
    if (!_assetFetchOptions) {
        _assetFetchOptions = [PHFetchOptions new];
    }
    return _assetFetchOptions;
}
- (void)setAssetGroupTypes:(NSArray<NSNumber *> *)assetGroupTypes{
    if (_assetGroupTypes != assetGroupTypes) {
        _assetGroupTypes = assetGroupTypes;
        [[DKImageManager shareInstance] groupDataManager].assetGroupTypes = assetGroupTypes;
    }
}
- (void)setAssetType:(DKImagePickerControllerAssetType)assetType{
    if (_assetType != assetType) {
        _assetType = assetType;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}

- (void)setShowsEmptyAlbums:(BOOL)showsEmptyAlbums{
    if (_showsEmptyAlbums != showsEmptyAlbums) {
        _showsEmptyAlbums = showsEmptyAlbums;
        [[DKImageManager shareInstance] groupDataManager].showsEmptyAlbums = showsEmptyAlbums;
    }
}

- (void)setAssetFilter:(BOOL (^)(PHAsset *))assetFilter{
    if (_assetFilter != assetFilter) {
        _assetFilter = assetFilter;
        [[DKImageManager shareInstance] groupDataManager].assetFilter = assetFilter;
        
    }
}

- (void)setSourceType:(DKImagePickerControllerSourceType)sourceType {
    if (_sourceType != sourceType) {
        _sourceType = sourceType;
        _hasInitialized = NO;
        
    }
}
- (DKImagePickerControllerDefaultUIDelegate *)UIDelegate{
    if (!_UIDelegate) {
        _UIDelegate  = [DKImagePickerControllerDefaultUIDelegate new];
    }
    return _UIDelegate;
    
}

- (void)setImageFetchPredicate:(NSPredicate *)imageFetchPredicate{
    if (_imageFetchPredicate != imageFetchPredicate) {
        _imageFetchPredicate = imageFetchPredicate;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}
- (void)setVideoFetchPredicate:(NSPredicate *)videoFetchPredicate{
    if (_videoFetchPredicate != videoFetchPredicate) {
        _videoFetchPredicate  = videoFetchPredicate;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}
- (void)setAutoDownloadWhenAssetIsInCloud:(BOOL)autoDownloadWhenAssetIsInCloud{
    if (_autoDownloadWhenAssetIsInCloud != autoDownloadWhenAssetIsInCloud) {
        _autoDownloadWhenAssetIsInCloud = autoDownloadWhenAssetIsInCloud;
        [DKImageManager shareInstance].autoDownloadWhenAssetIsInCloud = YES;
    }
}

- (void)setDefaultSelectedAssets:(NSArray<DKAsset *> *)defaultSelectedAssets{
    if (_defaultSelectedAssets != defaultSelectedAssets) {
        _defaultSelectedAssets = defaultSelectedAssets;
        self.selectedAssets = defaultSelectedAssets.copy;
        if ([self.viewControllers.firstObject isKindOfClass:[DKAssetGroupDetailVC class]]) {
            DKAssetGroupDetailVC * vc = (DKAssetGroupDetailVC *)self.viewControllers.firstObject;
            [vc.collectionView reloadData];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHFetchOptions *)createAssetFetchOptions{
    
    NSPredicate * (^createImagePredicate)() = ^{
       NSPredicate * imagePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mediaType == %ld", (long)PHAssetMediaTypeImage]];
        if (self.imageFetchPredicate) {
            imagePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[imagePredicate, self.imageFetchPredicate]];
        }
        return imagePredicate;
    };
    
    NSPredicate * (^createVideoPredicate)() = ^{
        NSPredicate * videoPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mediaType == %ld", (long)PHAssetMediaTypeVideo]];
        if (self.videoFetchPredicate) {
            videoPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[videoPredicate, self.videoFetchPredicate]];
        }
        return videoPredicate;
    };
    
    
    NSPredicate * predicate;
    switch (self.assetType) {
        case DKImagePickerControllerAssetAllAssetsType:
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[createImagePredicate(), createVideoPredicate()]];
            break;
        case DKImagePickerControllerAssetAllPhotosType:
            predicate = createImagePredicate();
            break;
        case DKImagePickerControllerAssetAllVideosType:
            predicate = createVideoPredicate();
            break;
        default:
            break;
    }
    self.assetFetchOptions.predicate = predicate;
    return self.assetFetchOptions;
}
- (void)selectImage:(DKAsset *)asset{
    if (self.singleSelect) {
        [self deselectAllAssets];
        [self.selectedAssets addObject:asset];
        [self done];
    }else{
        [self.selectedAssets addObject:asset];
        if (self.sourceType == DKImagePickerControllerSourceCameraType) {
            [self done];
        }else{
            [self.UIDelegate imagePickerController:self didSelectAssets:@[asset]];
        }
    }
}

- (void)deselectAllAssets{
    if (self.selectedAssets.count > 0) {
        NSArray * assets = [self.selectedAssets copy];
        [self.selectedAssets removeAllObjects];
        [self.UIDelegate imagePickerController:self didDeselectAssets:assets];
        UIViewController * vc = self.viewControllers.firstObject;
        if ([vc isKindOfClass:[DKAssetGroupDetailVC class]]) {
            [((DKAssetGroupDetailVC *)vc).collectionView reloadData];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
