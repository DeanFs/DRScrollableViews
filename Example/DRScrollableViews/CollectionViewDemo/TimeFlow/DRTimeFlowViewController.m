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
#import <DRScrollableViews/DRTimeFlowView.h>
#import <HexColors/HexColors.h>

@interface DRTimeFlowViewController ()<DRTimeFlowViewDelegate, DRTimeFlowViewDataSource>

@property (weak, nonatomic) IBOutlet DRTimeFlowView *timeFlowView;

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) NSInteger current;
@property (nonatomic, copy) NSString *reuseIdentifier;

@end

@implementation DRTimeFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reuseIdentifier = NSStringFromClass([DRTimeFlowCell class]);
    self.view.backgroundColor = [UIColor grayColor];
    self.timeFlowView.backgroundColor = [UIColor grayColor];
    [self.timeFlowView registerNib:[UINib nibWithNibName:self.reuseIdentifier bundle:nil] forCellWithReuseIdentifier:self.reuseIdentifier];
    self.timeFlowView.maxItemSize = CGSizeMake(kDRScreenWidth-56, kMaxCellHeight);
    self.timeFlowView.decreasingStep = kDecreasingStep;
    self.timeFlowView.coverOffset = kBottomCoverHeight;
    self.timeFlowView.delegate = self;
    self.timeFlowView.dataSource = self;
    
    // 延时模拟网络请求
    self.itemCount = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.itemCount = 20;
        self.current = self.itemCount;
        [self.timeFlowView reloadData];
    });
}

#pragma mark- DRTimeFlowViewDataSource
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView {
    return self.itemCount;
}

- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView cellForRowAtIndex:(NSInteger)index {
    DRTimeFlowCell *cell = [timeFlowView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndex:index];
    [cell setupWithDay:self.current-index-1];
    return cell;
}

#pragma mark - DRTimeFlowViewDelegate
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldSelectRowAtIndex:(NSInteger)index {
    return YES;
}

- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didSelectRowAtIndex:(NSInteger)index {
    kDR_LOG(@"click %ld", index);
}

// 加载更多
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScrollToBottom:(UIScrollView *)scrollView {
    // 延时模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.itemCount < 100) {
            self.itemCount += 10;
        }
        [timeFlowView reloadData];
    });
}

@end
