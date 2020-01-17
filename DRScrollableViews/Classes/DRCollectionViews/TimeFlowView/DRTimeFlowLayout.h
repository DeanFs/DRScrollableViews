//
//  DRTimeFlowLayout.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import <UIKit/UIKit.h>
#import "DRTimeFlowViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRTimeFlowLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize maxItemSize; // 最大的cell的size
@property (nonatomic, assign) CGFloat decreasingStep; // cell高度递减的值
@property (nonatomic, assign) CGFloat coverOffset; // 上一个cell被遮盖的高度值
@property (nonatomic, assign, readonly) NSInteger cellCount;          // 当前cell总数
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *visibleIndexs; // 当前可见的cell序号集合
@property (strong, nonatomic) UIView<DRTimeFlowViewRefreshViewProtocol> *headerRefreshView;
@property (strong, nonatomic) UIView<DRTimeFlowViewRefreshViewProtocol> *footerRefreshView;

- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex;
- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex hideIndex:(NSInteger)hideIndex;

@end

NS_ASSUME_NONNULL_END
