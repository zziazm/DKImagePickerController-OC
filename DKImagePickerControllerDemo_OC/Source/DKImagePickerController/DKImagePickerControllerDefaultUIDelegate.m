//
//  DKImagePickerControllerDefaultUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKAssetGroupGridLayout.h"
#import "DKImageResource.h"
#import "DKAssetGroupDetailCameraCell.h"
#import "DKAssetGroupDetailVideoCell.h"
#import "DKAssetGroupDetailImageCell.h"
@implementation DKImagePickerControllerDefaultUIDelegate
- (UIButton *)createDoneButtonIfNeede{
    if (!self.doneButton) {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setTitleColor:[UINavigationBar appearance].tintColor?:self.imagePickerController.navigationBar.tintColor forState:UIControlStateNormal];
        [self.doneButton addTarget:self.imagePickerController action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [self updateDoneButtonTitle:self.doneButton];
    }
       return self.doneButton;
}

- (void)updateDoneButtonTitle:(UIButton *)button{

    [button sizeToFit];
}

#pragma mark -- DKImagePickerControllerUIDelegate
- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc{
    self.imagePickerController = imagePickerController;
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createDoneButtonIfNeede]];
    
}

- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController {
    return [DKAssetGroupGridLayout new];
}

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       showsCancelButtonForVC:(UIViewController *)vc{
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:imagePickerController action:@selector(dismiss)];
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
       hidesCancelButtonForVC:(UIViewController *)vc{
    vc.navigationItem.leftBarButtonItem = nil;
}

- (void)imagePickerController:(DKImagePickerController *)imagePickerController
              didSelectAssets:(NSArray <DKAsset *> *)didSelectAssets{
    [self updateDoneButtonTitle:[self createDoneButtonIfNeede]];
}
- (void)imagePickerController:(DKImagePickerController *)imagePickerController
            didDeselectAssets:(NSArray <DKAsset *> *)didDeselectAssets{
    [self updateDoneButtonTitle:[self createDoneButtonIfNeede]];

}

- (void)imagePickerControllerDidReachMaxLimit:(DKImagePickerController *)imagePickerController{
    UIAlertController * alert = [UIAlertController  alertControllerWithTitle:DKImageLocalizedStringWithKey(@"maxLimitReached") message:[NSString stringWithFormat:@"%@", DKImageLocalizedStringWithKey(@"maxLimitReachedMessage")] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:DKImageLocalizedStringWithKey(@"ok") style:UIAlertActionStyleCancel handler:nil]];
    [imagePickerController presentViewController:alert animated:YES completion:nil];
}

- (Class)imagePickerControllerCollectionImageCell{
    return [DKAssetGroupDetailImageCell class];
}
- (Class)imagePickerControllerCollectionCameraCell{
    return [DKAssetGroupDetailCameraCell class];
}
- (Class)imagePickerControllerCollectionVideoCell{
    return [DKAssetGroupDetailVideoCell class];
}
- (UIColor *)imagePickerControllerCollectionViewBackgroundColor {
    return [UIColor whiteColor];
}
- (UIView *)imagePickerControllerFooterView:(DKImagePickerController *)imagePickerController{
    return  nil;
}
@end
