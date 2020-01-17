//
//  DRTimeFlowViewProtocol.h
//  DRCategories
//
//  Created by 冯生伟 on 2020/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DRTimeFlowView;
@protocol DRTimeFlowViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInTimeFlowView:(DRTimeFlowView *)timeFlowView;
- (UICollectionViewCell *)timeFlowView:(DRTimeFlowView *)timeFlowView
                     cellForRowAtIndex:(NSInteger)index;

@end

@protocol DRTimeFlowViewDelegate <NSObject>

@optional

// 长按手势识别
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView onLongPressGestureStateChange:(UIGestureRecognizerState)longPressGestureState longPressGesture:(UILongPressGestureRecognizer *)longPressGesture;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView isDragging:(BOOL)isDragging;

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
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScrollToBottom:(UIScrollView *)scrollView; // 往下记载更多数据
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScrollToTop:(UIScrollView *)scrollView; // 往上加载更多数据
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didScroll:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willBeginDragging:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView willBeginDecelerating:(UIScrollView *)scrollView;
- (void)timeFlowView:(DRTimeFlowView *)timeFlowView didEndDecelerating:(UIScrollView *)scrollView;

@end


typedef NS_ENUM(NSInteger, DRTimeFlowPullRefreshStatus) {
    DRTimeFlowPullRefreshStatusNormal,
    DRTimeFlowPullRefreshStatusPrepared,
    DRTimeFlowPullRefreshStatusLoading,
    DRTimeFlowPullRefreshStatusNoMoreData,
    DRTimeFlowPullRefreshStatusRest
};
@protocol DRTimeFlowViewRefreshViewProtocol <NSObject>

- (void)setStatus:(DRTimeFlowPullRefreshStatus)status;
- (DRTimeFlowPullRefreshStatus)currentStatus;
- (CGFloat)refreshViewHeight;

@end

NS_ASSUME_NONNULL_END
