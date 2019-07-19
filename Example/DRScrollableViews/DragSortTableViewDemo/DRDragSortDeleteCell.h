//
//  DRDragSortDeleteCell.h
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/19.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRDragSortDeleteModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL canSort;
@property (nonatomic, assign) BOOL canDelete;

@end


@interface DRDragSortDeleteCell : UITableViewCell

- (void)setupWithModel:(DRDragSortDeleteModel *)model;

@end

