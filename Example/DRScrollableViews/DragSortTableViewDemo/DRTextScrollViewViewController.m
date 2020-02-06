//
//  DRTextScrollViewViewController.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2020/2/6.
//  Copyright © 2020 Dean_F. All rights reserved.
//

#import "DRTextScrollViewViewController.h"
#import <DRScrollableViews/DRTextScrollView.h>

@interface DRTextScrollViewViewController ()

@property (weak, nonatomic) IBOutlet DRTextScrollView *textScrollView;

@end

@implementation DRTextScrollViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textScrollView.textColor = [UIColor redColor];
    self.textScrollView.textFont = [UIFont systemFontOfSize:22];
    self.textScrollView.textAlignmant = NSTextAlignmentCenter;
    self.textScrollView.animateDurtaion = 5;
    self.textScrollView.textList = @[@"dflakd", @"flakdjfladjflajdlfjalkdjflakd", @"你好大家安利的会计法代理费卡进来", @"你发放到"];
    [self.textScrollView startAnimation];
    [self.textScrollView autoDeallocWithObj:self];
}



@end
