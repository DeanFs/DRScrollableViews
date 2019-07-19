//
//  DRTimeFlowCell.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/17.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRTimeFlowCell.h"
#import <HexColors/HexColors.h>

@implementation DRTimeFlowModel

@end

@interface DRTimeFlowCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayNameLabelWidth;

@end

@implementation DRTimeFlowCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupWithModel:(DRTimeFlowModel *)model {
    self.dayNameLabelWidth.constant = 10;
    self.dayNameLabel.hidden = NO;
    self.dayLabel.textColor = [UIColor hx_colorWithHexRGBAString:@"#4BA2F3"];
    self.dayLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:25];
    if (model.day == 0) {
        self.dayLabel.text = @"今";
    } else if (model.day < 0) {
        self.dayNameLabelWidth.constant = 0;
        self.dayNameLabel.hidden = YES;
        self.dayLabel.textColor = [UIColor hx_colorWithHexRGBAString:@"#B8BFCD"];
        self.dayLabel.text = @"已结束";
        self.dayLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    } else {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld", model.day];
    }
    
    self.titleLabel.text = model.title;
    self.descLabel.text = model.desc;
}

@end
