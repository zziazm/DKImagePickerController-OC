//
//  DKGroupDataManager.h
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@class DKAssetGroup;
@class DKAsset;
@interface DKGroupDataManager : NSObject

@property (nonatomic, strong) NSMutableArray <NSString *>* groupIds;
@property (nonatomic, strong) NSMutableDictionary <NSString * , DKAssetGroup *>* groups;
@property (nonatomic, strong) NSMutableDictionary <NSString * , DKAsset *>* assets;

@property (nonatomic, copy) NSArray <NSNumber *> * assetGroupTypes;

@property (nonatomic, strong) PHFetchOptions * assetFetchOptions;
@property (nonatomic, assign) BOOL showsEmptyAlbums;

@property (nonatomic, copy) BOOL(^assetFilter)(PHAsset * asset);
- (DKAssetGroup *)fetchGroupWithGroupId:(NSString *)groupId;
- (void)fetchGroupsWithCompleteBlock:(void(^)(NSArray <NSString *> * groupIds, NSError * error))completeBlock;
- (void)fetchGroupThumbnailForGroup:(NSString *)groupId
                               size:(CGSize)size
                            options:(PHImageRequestOptions *)options
                      completeBlock:(void(^)(UIImage * image, NSDictionary * info))completeBlock;
- (DKAsset *)fetchAsset:(DKAssetGroup *)group
                  index:(NSInteger)index;
- (PHFetchResult <PHAsset *>*)filterResults:(PHFetchResult <PHAsset *>*)fetchResult;
@end
