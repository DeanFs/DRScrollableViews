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
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, strong) NSIndexPath *lastIndex;

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
    
    self.itemCount = arc4random() % 10 + 7;
}

#pragma mark- DRTimeFlowViewDataSource
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView {
    return self.itemCount;
}

- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DRTimeFlowCell *cell = [timeFlowView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
    [cell setupWithDay:self.itemCount-indexPath.row-1];
    return cell;
}

#pragma mark - DRTimeFlowViewDelegate
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kDR_LOG(@"click %ld", indexPath.row);
}

@end
