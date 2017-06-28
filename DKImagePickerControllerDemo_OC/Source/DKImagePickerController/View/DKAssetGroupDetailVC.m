//
//  DKAssetGroupDetailVC.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/27.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupDetailVC.h"
#import "DKImagePickerController.h"
#import "DKImageManager.h"
#import "DKGroupDataManager.h"
#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKAsset.h"
#import "DKAssetGroup.h"
#import "DKAssetGroupDetailBaseCell.h"
#import "DKAssetGroupDetailImageCell.h"
#import "DKAssetGroupDetailVideoCell.h"
#import "DKAssetGroupDetailCameraCell.h"
@implementation UICollectionView(DKExtension)

- (NSArray <NSIndexPath *>*)indexPathsForElementsInRect:(CGRect)rect
                                            hidesCamera:(BOOL)hidesCamera{
    NSArray * allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray * tem = @[].mutableCopy;
    if (hidesCamera) {
        for (UICollectionViewLayoutAttributes * la in allLayoutAttributes) {
            [tem addObject:la.indexPath];
        }
        return tem;
    }else{
        for (UICollectionViewLayoutAttributes * la in allLayoutAttributes) {
            if (la.indexPath.item == 0) {
                
            }else{
                NSIndexPath * idx = [NSIndexPath indexPathForRow:la.indexPath.item - 1 inSection:la.indexPath.section];
                [tem addObject:idx];

            }
        }
        return tem;
    }
}

@end


@interface DKAssetGroupDetailVC ()
@property (nonatomic, strong) UIButton * selectGroupButton;
@property (nonatomic, copy) NSString * selectedGroupId;
@property (nonatomic, assign) BOOL hidesCamera;
@property (nonatomic, strong) UIView * footerView;
@property (nonatomic, assign) CGSize currentViewSize;
@property (nonatomic, strong) NSMutableSet * registeredCellIdentifiers;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, assign) CGRect previousPreheatRect;
@end

@implementation DKAssetGroupDetailVC

- (id)init{
    if (self = [super init]) {
        _hidesCamera = NO;
        _thumbnailSize = CGSizeZero;
        _registeredCellIdentifiers = [NSMutableSet new];
        _previousPreheatRect = CGRectZero;
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (CGSizeEqualToSize(_currentViewSize, self.view.bounds.size)) {
        return;
    }else{
        _currentViewSize = self.view.bounds.size;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewLayout * layout = [self.imagePickerController.UIDelegate layoutForImagePickerController:self.imagePickerController];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [self.imagePickerController.UIDelegate imagePickerControllerCollectionViewBackgroundColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    self.footerView = [self.imagePickerController.UIDelegate imagePickerControllerFooterView:self.imagePickerController];
    if (self.footerView) {
        [self.view addSubview:self.footerView];
    }
    
    self.hidesCamera = self.imagePickerController.sourceType == DKImagePickerControllerSourcePhotoType;
    // Do any additional setup after loading the view.
}


- (UIButton *)selectGroupButton{
    if (!_selectGroupButton) {
        _selectGroupButton = [UIButton new];
        UIColor * globalTitleColor = [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
        [_selectGroupButton setTitleColor:globalTitleColor?:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIFont * globalTitleFont =  [UINavigationBar appearance].titleTextAttributes[NSFontAttributeName];
        
        _selectGroupButton.titleLabel.font = globalTitleFont?:[UIFont boldSystemFontOfSize:18];
        [_selectGroupButton addTarget:self action:@selector(showGroupSelector) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectGroupButton;
}

- (void)checkPhotoPermission{
     [DKImageManager checkPhotoPermissionWithHandle:^(BOOL granted) {
         granted ? [self setup] : [self photoDenied];
     }];
}
- (void)photoDenied{
    
}
- (void)setup{
    [self resetCachedAssets];
//    [DKImageManager shareInstance]
}

- (void)selectAssetGroup:(NSString * )groupId{
    if ([self.selectedGroupId  isEqualToString:groupId]) {
        [self updateTitleView];
        return;
    }
    self.selectedGroupId = groupId;
    [self updateTitleView];
    [self.collectionView reloadData];
}


- (void)updateTitleView{
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    self.title = group.groupName;
    NSInteger groupsCount = [[[[DKImageManager shareInstance] groupDataManager] groupIds] count];
    [self.selectGroupButton setTitle:[NSString stringWithFormat:@"%@%@", group.groupName, groupsCount > 1 ? @"???" : @""] forState:UIControlStateNormal];
    [self.selectGroupButton sizeToFit];
    self.selectGroupButton.enabled = groupsCount > 1;
    self.navigationItem.titleView = self.selectGroupButton;

}

- (DKAsset *)fetchAsset:(NSInteger)index{
    if (!self.hidesCamera && index == 0) {
        return nil;
    }
    NSInteger assetIndex = index - (self.hidesCamera ? 0 : 1);
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    DKAsset * asset = [[[DKImageManager shareInstance] groupDataManager] fetchAsset:group index:index];
    return asset;
}

#pragma mark -- UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!self.selectedGroupId) {
        return 0;
    }
    
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    return group.totalCount + (self.hidesCamera ? 0 : 1);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DKAssetGroupDetailBaseCell * cell;
    if ([self isCameraCell:indexPath]) {
        cell = [self dequeueReusableCameraCellForIndexPath:indexPath];
    }else{
        cell = [self dequeueReusableCellForIndexPath:indexPath];
    }
    return cell;
}

- (DKAssetGroupDetailBaseCell *)dequeueReusableCameraCellForIndexPath:(NSIndexPath *)indexPath{
    [self registerCellifNeededWithCellClass:[DKAssetGroupDetailCameraCell class] cellReuseIdentifier:[DKAssetGroupDetailCameraCell cellReuseIdentifier]];
    DKAssetGroupDetailBaseCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[DKAssetGroupDetailCameraCell cellReuseIdentifier] forIndexPath:indexPath];
    return cell;
}
- (DKAssetGroupDetailBaseCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath{
    DKAsset * asset = [self fetchAsset:indexPath.item];
    Class cellCls;
    NSString * cellId;
    if (asset.isVideo) {
        cellCls = [DKAssetGroupDetailVideoCell class];
        cellId = [DKAssetGroupDetailVideoCell cellReuseIdentifier];
    }else{
        cellCls = [DKAssetGroupDetailImageCell class];
        cellId = [DKAssetGroupDetailImageCell cellReuseIdentifier];
    }
    
    [self registerCellifNeededWithCellClass:cellCls cellReuseIdentifier:cellId];
    DKAssetGroupDetailBaseCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    return cell;
}
- (void)registerCellifNeededWithCellClass:(Class)cellClass cellReuseIdentifier:(NSString *)cellReuseIdentifier{
    if (![self.registeredCellIdentifiers containsObject:cellReuseIdentifier]) {
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
        [self.registeredCellIdentifiers addObject:cellReuseIdentifier];
    }
}

- (BOOL)isCameraCell:(NSIndexPath * )indexPath{
    return indexPath.row == 0 && !self.hidesCamera;
}
- (void)resetCachedAssets{
    [[DKImageManager shareInstance] stopCachingForAllAssets];
    self.previousPreheatRect = CGRectZero;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
