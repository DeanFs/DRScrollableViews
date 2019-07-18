//
//  DRTimeFlowCell.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/17.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRTimeFlowCell.h"
#import <HexColors/HexColors.h>

@interface DRTimeFlowCell ()

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@end

@implementation DRTimeFlowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 4;
    self.layer.borderColor = self.backgroundColor.CGColor;
    self.layer.borderWidth = 1;
    self.layer.shadowColor = [UIColor hx_colorWithHexRGBAString:@"#D6E7F4"].CGColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat rate = (height - kDecreasingStep) / height;
        CGFloat neWidth = width * rate;
        CGRect shadowRect = CGRectInset(self.bounds, (width-neWidth)/2, 4);
        shadowRect = CGRectOffset(shadowRect, 0, -5);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
    });
}

- (void)layoutSubviews {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat rate = (height - kDecreasingStep) / height;
    CGFloat neWidth = width * rate;
    CGRect shadowRect = CGRectInset(self.bounds, (width-neWidth)/2, 4);
    shadowRect = CGRectOffset(shadowRect, 0, -5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
}

- (void)setupWithDay:(NSInteger)day {
    if (day == 0) {
        self.dayLabel.text = @"今";
    } else {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld", day];
    }
}

@end
