//
//  DRTimeFlowPullRefreshView.h
//  DRCategories
//
//  Created by 冯生伟 on 2020/1/17.
//

#import <UIKit/UIKit.h>
#import <DRScrollableViews/DRTimeFlowViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRTimeFlowPullRefreshView : UIView<DRTimeFlowViewRefreshViewProtocol>

@property (strong, nonatomic) UIColor *refreshLabelColor;

+ (instancetype)headerView;
+ (instancetype)footerView;

@end

NS_ASSUME_NONNULL_END
