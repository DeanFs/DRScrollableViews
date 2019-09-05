//
//  DRFoldableOptionCell.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/9/4.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRFoldableOptionCell.h"

@interface DRFoldableOptionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DRFoldableOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)refreshWithModel:(DRFoldableItemModel *)model {
    self.itemImageView.image = [UIImage imageNamed:model.imageName];
    self.titleLabel.text = model.title;
}

@end
