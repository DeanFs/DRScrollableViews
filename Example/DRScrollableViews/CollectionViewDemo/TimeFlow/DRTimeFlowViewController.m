//
//  DRTimeFlowViewController.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/17.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRTimeFlowViewController.h"
#import "DRTimeFlowCell.h"
#import <DRCategories/DRCategories.h>
#import <DRMacroDefines/DRMacroDefines.h>
#import <DRScrollableViews/DRTimeFlowLayout.h>

@interface DRTimeFlowViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation DRTimeFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    self.reuseIdentifier = NSStringFromClass([DRTimeFlowCell class]);
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:self.reuseIdentifier];
    
    DRTimeFlowLayout *layout = (DRTimeFlowLayout *)self.collectionView.collectionViewLayout;
    layout.maxItemSize = CGSizeMake(kDRScreenWidth-56, 74);
    layout.decreasingStep = 4;
    layout.coverOffset = 4;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.itemCount = arc4random() % 10 + 5;
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemCount;;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DRTimeFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    [cell setupWithDay:self.itemCount-indexPath.row-1];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    kDR_LOG(@"click %ld", indexPath.row);
}

@end
