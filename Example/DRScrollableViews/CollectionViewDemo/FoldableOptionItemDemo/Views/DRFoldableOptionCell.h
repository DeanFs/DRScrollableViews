//
//  DRFoldableOptionCell.h
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/9/4.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRFoldableItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRFoldableOptionCell : UICollectionViewCell

- (void)refreshWithModel:(DRFoldableItemModel *)model;

@end

NS_ASSUME_NONNULL_END
