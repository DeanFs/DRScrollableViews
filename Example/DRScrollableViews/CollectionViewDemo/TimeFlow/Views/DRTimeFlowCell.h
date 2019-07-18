//
//  DRTimeFlowCell.h
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/17.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kDecreasingStep 4
#define kBottomCoverHeight 4
#define kMaxCellHeight 74

@interface DRTimeFlowCell : UICollectionViewCell

- (void)setupWithDay:(NSInteger)day;

@end

NS_ASSUME_NONNULL_END