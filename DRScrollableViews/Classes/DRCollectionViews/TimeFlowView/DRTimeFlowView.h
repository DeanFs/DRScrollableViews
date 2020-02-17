//
//  DRTimeFlowView.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import <UIKit/UIKit.h>
#import "DRTimeFlowViewProtocol.h"

@interface DRTimeFlowView : UIView

@property (nonatomic, assign) IBInspectable CGSize maxItemSize; // 最大的cell的size，默认(screen_width-56, 74)
@property (nonatomic, assign) IBInspectable CGFloat decreasingStep; // cell高度递减的值，默认4
@property (nonatomic, assign) IBInspectable CGFloat coverOffset; // 上一个cell被遮盖的高度值，默认4
@property (nonatomic, assign) IBInspectable BOOL bouncesEnable; // 是否可以回弹
@property (nonatomic, assign) IBInspectable CGFloat cellCornerRadius; // cell圆角半径，默认4
@property (nonatomic, strong) IBInspectable UIColor *cellShadowColor; // cell阴影的颜色，默认0xD6E7F4
@property (nonatomic, assign) IBInspectable CGFloat cellShadowOffset; // 可见阴影长度, 默认20
@property (nonatomic, assign) CGPoint contentOffset;
@property (assign, nonatomic) UIEdgeInsets contentInset;
@property (strong, nonatomic) UIColor *refreshLabelColor;

@property (nonatomic, weak) id<DRTimeFlowViewDataSource> dataSource;
@property (nonatomic, weak) id<DRTimeFlowViewDelegate> delegate;
@property (weak, nonatomic) UIView<DRTimeFlowViewRefreshViewProtocol> *headerRefreshView;
@property (weak, nonatomic) UIView<DRTimeFlowViewRefreshViewProtocol> *footerRefreshView;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                                 forIndex:(NSInteger)index;
- (__kindof UICollectionViewCell *)cellAtIndex:(NSInteger)index;

// 获取当前显示的第一个cell的序号
- (NSInteger)currentTopCellIndex;
// 获取当前显示的最底部一个cell的序号
- (NSInteger)currentBottomCellIndex;
// 动画设置偏移量
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
// 滚动，将可见cell的第一个置为第index个
- (void)scrollToTopIndex:(NSInteger)index animated:(BOOL)animated;
// 设置最底部cell的index，即将底index个cell滚动到底部
- (void)scrollToBottomIndex:(NSInteger)index animated:(BOOL)animated;
// 刷新显示，并将第bottomIndex个cell定位在底部
- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex;
// 刷新显示，并将第bottomIndex个cell定位在底部，并将第hideIndex个cell设置为透明
- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex hideCellAtIndex:(NSInteger)hideIndex;
// 尾部加载更多数据
- (void)realoadAppendData;
// 刷新显示
- (void)reloadData;

#pragma mark - 上下拉刷新
- (void)endHeaderRefreshing;
- (void)endHeaderRefreshingWithNoMoreData;
- (void)headerRefreshRest;
- (void)endFooterRefreshing;
- (void)endFooterRefreshingWithNoMoreData;
- (void)footerRefreshRest;

@end
