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

@property (nonatomic, assign) NSInteger current;
@property (nonatomic, copy) NSString *reuseIdentifier;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation DRTimeFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reuseIdentifier = NSStringFromClass([DRTimeFlowCell class]);
    self.view.backgroundColor = [UIColor grayColor];
    self.timeFlowView.backgroundColor = [UIColor grayColor];
    
    self.timeFlowView.cellShadowColor = [UIColor hx_colorWithHexRGBAString:@"ECD2C188"];
    [self.timeFlowView registerNib:[UINib nibWithNibName:self.reuseIdentifier bundle:nil] forCellWithReuseIdentifier:self.reuseIdentifier];
    self.timeFlowView.delegate = self;
    self.timeFlowView.dataSource = self;
    
    // 延时模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.current = arc4random() % 15;
        [self makeDateWithCount:arc4random() % 200 + 15];
        [self.timeFlowView reloadDataScrollToBottomIndex:self.current];
    });
}

#pragma mark- DRTimeFlowViewDataSource
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView {
    return self.datas.count;
}

- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView cellForRowAtIndex:(NSInteger)index {
    DRTimeFlowCell *cell = [timeFlowView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndex:index];
    [cell setupWithModel:self.datas[index]];
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
        if (self.datas.count < 300) {
            [self makeDateWithCount:50];
            [timeFlowView realoadAppendData];
        }
    });
}

- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldDeleteRowAtIndex:(NSInteger)index {
    return index <= self.current;
}

- (void)timeFlowView:(DRTimeFlowView *)timeFlowView beginDeleteRowAtIndex:(NSInteger)index whenComplete:(void (^)(BOOL))complete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.datas removeObjectAtIndex:index];
        complete(YES);
    });
}

#pragma mark - private
- (void)makeDateWithCount:(NSInteger)count {
    if (!self.datas) {
        self.datas = [NSMutableArray array];
    }
    NSArray *titles = @[@"高考",
                        @"相亲",
                        @"旅游",
                        @"国庆节",
                        @"还款日",
                        @"生理期",
                        @"宝贝生日",
                        @"一周年结婚几年日",
                        @"这是一个很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长的标题"];
    NSArray *descs = @[@"6/08  这是最重要的一天",
                       @"6/20  包含3张图片",
                       @"6/20  内蒙古",
                       @"10/01",
                       @"08/20",
                       @"06/20",
                       @"06/26",
                       @"06/20 记得给宝贝惊喜",
                       @"06/06 就问你长不长"];
    for (NSInteger i=0; i<count; i++) {
        DRTimeFlowModel *model = [DRTimeFlowModel new];
        model.title = titles[self.datas.count % titles.count];
        model.desc = descs[self.datas.count % descs.count];
        model.day = self.current - self.datas.count;
        [self.datas addObject:model];
    }
}

@end
