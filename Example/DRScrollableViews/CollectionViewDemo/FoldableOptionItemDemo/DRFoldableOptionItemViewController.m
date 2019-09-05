//
//  DRFoldableOptionItemViewController.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/9/4.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRFoldableOptionItemViewController.h"
#import "DRFoldableOptionCell.h"
#import "DRFoldableOptionItemView.h"
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRFoldableOptionItemViewController () <DRFoldableOptionItemViewDelegate, DRFoldableOptionItemViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet DRFoldableOptionItemView *foldableOptionView;

@property (nonatomic, strong) NSArray<DRFoldableItemModel *> *datas;

@end

@implementation DRFoldableOptionItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    NSMutableArray *datas = [NSMutableArray array];
    for (NSInteger i=0; i<10; i++) {
        [datas addObject:[DRFoldableItemModel modelWithTitle:[NSString stringWithFormat:@"标题_%ld", i]
                                                   imageName:[NSString stringWithFormat:@"icon_foldable%ld", i]]];
    }
    self.datas = datas;
    
    self.foldableOptionView.delegate = self;
    self.foldableOptionView.dataSource = self;
    [self.foldableOptionView registerNib:[UINib nibWithNibName:NSStringFromClass([DRFoldableOptionCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DRFoldableOptionCell class])];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = @"下拉查看下程序";
    return cell;
}

#pragma mark - DRFoldableOptionItemViewDataSource
- (NSInteger)numberOfItemsInFoldableOptionItemView:(DRFoldableOptionItemView *)optionItemView {
    return self.datas.count;
}

- (UICollectionViewCell *)foldableOptionItemView:(DRFoldableOptionItemView *)foldableOptionItemView cellForItemAtIndex:(NSInteger)index {
    DRFoldableOptionCell *cell = [foldableOptionItemView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DRFoldableOptionCell class]) forIndex:index];
    [cell refreshWithModel:self.datas[index]];
    return cell;
}

#pragma mark - DRFoldableOptionItemViewDelegate
- (void)foldableOptionItemView:(DRFoldableOptionItemView *)foldableOptionItemView didSelectItemAtIndex:(NSInteger)index {
    kDR_LOG(@"选中第%ld项", index);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView.contentOffset.y <= 0) {
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        *targetContentOffset = CGPointMake(0, 0);
    } else {
        [self.tableView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offsetY = %f", scrollView.contentOffset.y);
    [self.foldableOptionView expandChangeToHeight:100 - scrollView.contentOffset.y];
}

@end
