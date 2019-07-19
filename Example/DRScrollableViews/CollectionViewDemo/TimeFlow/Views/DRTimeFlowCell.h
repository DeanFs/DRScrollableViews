//
//  DRTimeFlowCell.h
//  DRScrollableViews_Example
//
//  Created by 冯生伟 on 2019/7/17.
//  Copyright © 2019 Dean_F. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDecreasingStep 4
#define kBottomCoverHeight 4
#define kMaxCellHeight 74

@interface DRTimeFlowModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) NSInteger day;

@end

@interface DRTimeFlowCell : UICollectionViewCell

- (void)setupWithModel:(DRTimeFlowModel *)model;

@end
