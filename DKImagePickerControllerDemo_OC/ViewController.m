//
//  ViewController.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "ViewController.h"
#import "DKImagePickerController.h"
#import "DKAsset.h"
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *previewView;
@property (nonatomic, copy) NSArray <DKAsset *>*assets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
}

- (void)showImagePicker{
    _pickerController.defaultSelectedAssets = self.assets;
    [_pickerController setDidCancel:^{
        NSLog(@"didCancel");
    }];
    __weak typeof(self) weakSelf = self;
    [_pickerController setDidSelectAssets:^(NSArray <DKAsset *>* assets){
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.assets = assets;
        [strongSelf.previewView reloadData];
        
    }];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _pickerController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:_pickerController animated:YES completion:nil];

    
    
}


#pragma mark -- UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"start";
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showImagePicker];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  -- UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DKAsset * asset = self.assets[indexPath.row];
    
    UICollectionViewCell * cell;
    UIImageView * imageView;
    
    if (asset.isVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellVideo" forIndexPath:indexPath];
        imageView = [cell.contentView viewWithTag:1];
    }else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellImage" forIndexPath:indexPath];
        imageView = [cell.contentView viewWithTag:1];

    }
    
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    
    NSInteger tag = indexPath.row + 1;
    cell.tag = tag;
    [asset fetchImageWithSize:layout.itemSize completeBlock:^(UIImage *image, NSDictionary *info) {
        if (cell.tag == tag) {
            imageView.image = image;
        }
    }];
    return cell;
    
}
@end
