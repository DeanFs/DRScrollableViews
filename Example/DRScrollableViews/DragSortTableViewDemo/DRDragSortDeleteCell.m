//
//  DRDragSortDeleteCell.m
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/19.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import "DRDragSortDeleteCell.h"

@implementation DRDragSortDeleteModel

@end

@interface DRDragSortDeleteCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sortSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *deleteSwitch;
@property (nonatomic, weak) DRDragSortDeleteModel *model;

@end

@implementation DRDragSortDeleteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithModel:(DRDragSortDeleteModel *)model {
    self.model = model;
    self.titleLabel.text = model.title;
    self.sortSwitch.on = model.canSort;
    self.deleteSwitch.on = model.canDelete;
}

- (IBAction)onValueChange:(UISwitch *)sender {
    if (sender.tag == 0) {
        self.model.canSort = sender.on;
    } else {
        self.model.canDelete = sender.on;
    }
}

//#pragma mark - DRDragSortCellDelegate
//- (CGRect)canReactLongPressSubRect {
//    return CGRectMake(0, 0, 100, 90);
//}
//
//- (UIView *)subDragViewFromCellInDragSortTableView:(DRDragSortTableView *)tableView {
//    return self.titleLabel;
//}

@end
