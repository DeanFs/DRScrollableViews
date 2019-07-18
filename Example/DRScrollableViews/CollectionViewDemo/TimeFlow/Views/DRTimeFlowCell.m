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
}

- (void)setupWithDay:(NSInteger)day {
    if (day == 0) {
        self.dayLabel.text = @"今";
    } else {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld", day];
    }
}

@end
