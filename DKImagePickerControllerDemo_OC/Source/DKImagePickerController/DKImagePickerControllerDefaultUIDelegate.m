//
//  DKImagePickerControllerDefaultUIDelegate.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKAssetGroupGridLayout.h"
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

#pragma mark -- DKImagePickerControllerDefaultUIDelegate
- (void)prepareLayout:(DKImagePickerController *)imagePickerController
                   vc:(UIViewController *)vc{
    self.imagePickerController = imagePickerController;
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createDoneButtonIfNeede]];
}

//- (UICollectionViewLayout *)layoutForImagePickerController:(DKImagePickerController *)imagePickerController {
//    return <#expression#>
//}

@end
