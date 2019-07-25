//
//  DRTimeFlowView.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import <UIKit/UIKit.h>

@class DRTimeFlowView;
@protocol DRTimeFlowViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView;
- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView
                     cellForRowAtIndex:(NSInteger)index;

@end

@protocol DRTimeFlowViewDelegate <NSObject>

@optional

// refresh cells
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView
     willDisplayCell:(UICollectionViewCell *)cell
       forRowAtIndex:(NSInteger)index;

// selecte
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldSelectRowAtIndex:(NSInteger)index;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didSelectRowAtIndex:(NSInteger)index;
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldDeselectRowAtIndex:(NSInteger)index;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didDeselectRowAtIndex:(NSInteger)index;

// delete
// 是否可以删除该cell
- (BOOL)timeFlowView:(DRTimeFlowView *)timeFlowView shouldDeleteRowAtIndex:(NSInteger)index;
// 即将删除，底部右下角出现红圈删除区域
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willDeleteRowAtIndex:(NSInteger)index;
// 未拖拽到删除区域松手，取消删除
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView cancelDeleteRowAtIndex:(NSInteger)index;
/**
 开始删除，拖到了删除区域，并且已松手，请在该方法中执行网络请求
 注意：无论删除接口是否成功，接口返回后，请调用complete回调，否则CollectionView将不能滚动
      无需reloadData
 要使用拖动删除功能，必须实现该方法，否则不响应长按手势
 
 @param timeFlowView 时间流控件
 @param index 欲删除的cell的index
 @param complete 删除接口返回后调用
 */
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView beginDeleteRowAtIndex:(NSInteger)index whenComplete:(void(^)(BOOL deleteSuccess))complete;

// scroll
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScrollToBottom:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScroll:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willBeginDragging:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willBeginDecelerating:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didEndDecelerating:(UIScrollView *)scrollView;

@end

@interface DRTimeFlowView : UIView

@property (nonatomic, assign) IBInspectable CGSize maxItemSize; // 最大的cell的size，默认(screen_width-56, 74)
@property (nonatomic, assign) IBInspectable CGFloat decreasingStep; // cell高度递减的值，默认4
@property (nonatomic, assign) IBInspectable CGFloat coverOffset; // 上一个cell被遮盖的高度值，默认4
@property (nonatomic, assign) IBInspectable CGFloat cellCornerRadius; // cell圆角半径，默认4
@property (nonatomic, strong) IBInspectable UIColor *cellShadowColor; // cell阴影的颜色，默认0xD6E7F4
@property (nonatomic, assign) IBInspectable CGFloat cellShadowOffset; // 可见阴影长度, 默认18

@property (nonatomic, weak) id<DRTimeFlowViewDataSource> dataSource;
@property (nonatomic, weak) id<DRTimeFlowViewDelegate> delegate;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                                 forIndex:(NSInteger)index;
// 获取当前显示的第一个cell的序号
- (NSInteger)currentTopCellIndex;
// 获取当前显示的最底部一个cell的序号
- (NSInteger)currentBottomCellIndex;
// 设置最底部cell的index，即将底index个cell滚动到底部
- (void)scrollToBottomIndex:(NSInteger)index animated:(BOOL)animated;
// 刷新显示，并将第index个cell定位在底部
- (void)reloadDataScrollToIndex:(NSInteger)index;
// 刷新显示
- (void)reloadData;

@end
