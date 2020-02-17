//
//  DRTimeFlowView.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/18.
//

#import "DRTimeFlowView.h"
#import "DRTimeFlowLayout.h"
#import "DRSectorDeleteView.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <HexColors/HexColors.h>
#import <Masonry/Masonry.h>
#import <DRCategories/UIImage+DRExtension.h>
#import <DRCategories/NSDictionary+DRExtension.h>
#import "UICollectionViewCell+TimeFlowShadowLayer.h"
#import <DRCategories/UIView+DRExtension.h>

@interface DRTimeFlowView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) DRTimeFlowLayout *layout;

// delete
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@property (nonatomic, strong) NSIndexPath *longPressIndexPath;
@property (nonatomic, weak) UICollectionViewCell *dragCell; // 长按手势开始时的cell
@property (nonatomic, strong) UIImageView *dragImageView; // 拖拽的视图的截图

@property (nonatomic, assign) BOOL haveDrag; // 用于判断上拉到底部执行代理回调;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UICollectionViewCell *> *visibleCellsMap; // 缓存当前可见的cell

@end

@implementation DRTimeFlowView

#pragma mark - api
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)reuseIdentifier
                                                                 forIndex:(NSInteger)index {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                          forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (__kindof UICollectionViewCell *)cellAtIndex:(NSInteger)index {
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (void)setMaxItemSize:(CGSize)maxItemSize {
    _maxItemSize = maxItemSize;
    self.layout.maxItemSize = maxItemSize;
}

- (void)setDecreasingStep:(CGFloat)decreasingStep {
    _decreasingStep = decreasingStep;
    if (decreasingStep == 0) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self.collectionView setCollectionViewLayout:layout];
    } else {
        [self.collectionView setCollectionViewLayout:self.layout];
    }
    self.layout.decreasingStep = decreasingStep;
}

- (void)setCoverOffset:(CGFloat)coverOffset {
    _coverOffset = coverOffset;
    self.layout.coverOffset = coverOffset;
}

- (void)setBouncesEnable:(BOOL)bouncesEnable {
    _bouncesEnable = bouncesEnable;
    self.collectionView.bounces = bouncesEnable;
}

- (void)setDelegate:(id<DRTimeFlowViewDelegate>)delegate {
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(timeFlowView:beginDeleteRowAtIndex:whenComplete:)]) {
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGestureStateChange:)];
        [self.collectionView addGestureRecognizer:self.longGesture];
    }
}

// 获取当前显示的第一个cell的序号
- (NSInteger)currentTopCellIndex {
    CGFloat contentOffsetY = self.collectionView.contentOffset.y;
    if (contentOffsetY <= -CGRectGetHeight(self.collectionView.frame)) {
        return -1;
    }
    if (contentOffsetY > 0) {
        return (NSInteger)(contentOffsetY / self.maxItemSize.height);
    }
    return 0;
}

// 获取当前显示的最底部一个cell的序号
- (NSInteger)currentBottomCellIndex {
    CGFloat contentOffsetY = self.collectionView.contentOffset.y;
    if (contentOffsetY <= -CGRectGetHeight(self.collectionView.frame)) {
        return -1;
    }
    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    CGFloat contentHeight = self.collectionView.contentSize.height;
    CGFloat bottomOutSideHeight = contentHeight - contentOffsetY - height;
    NSInteger bottomOutSideCount = 0;
    if (bottomOutSideHeight > 0) {
        bottomOutSideCount = bottomOutSideHeight / self.maxItemSize.height;
    }
    return self.layout.cellCount - bottomOutSideCount - 1; // 最后一个可见cell的序号
}

- (void)setContentOffset:(CGPoint)contentOffset {
    self.collectionView.contentOffset = contentOffset;
}

// 动画设置偏移量
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [self.collectionView setContentOffset:contentOffset animated:animated];
}

- (CGPoint)contentOffset {
    return self.collectionView.contentOffset;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    self.collectionView.contentInset = contentInset;
}

- (UIEdgeInsets)contentInset {
    return self.collectionView.contentInset;
}

// 滚动，将可见cell的第一个置为第index个
- (void)scrollToTopIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.decreasingStep != 0) {
        return;
    }
    CGPoint offset = CGPointMake(0, (index-1)*self.maxItemSize.height);
    offset = [self.layout targetContentOffsetForProposedContentOffset:offset withScrollingVelocity:CGPointZero];
    [self.collectionView setContentOffset:offset
                                 animated:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupVisibleCells];
    });
}

// 设置最底部cell的index，即将底index个cell滚动到底部
- (void)scrollToBottomIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.decreasingStep != 0) {
        return;
    }
    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    CGFloat contentHeight = self.collectionView.contentSize.height;
    if (index >= self.layout.cellCount-1) {
        [self.collectionView setContentOffset:CGPointMake(0, contentHeight-height) animated:animated];
    } else {
        CGFloat outsideHeight = self.maxItemSize.height * (self.layout.cellCount-index-1);
        [self.collectionView setContentOffset:CGPointMake(0, contentHeight-outsideHeight-height) animated:animated];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupVisibleCells];
    });
}

// 刷新显示，并将第bottomIndex个cell定位在底部
- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout reloadDataScrollToBottomIndex:bottomIndex];
    [self.collectionView reloadData];
}

// 刷新显示，并将第bottomIndex个cell定位在底部，并将第hideIndex个cell设置为透明
- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex hideCellAtIndex:(NSInteger)hideIndex {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout reloadDataScrollToBottomIndex:bottomIndex hideIndex:hideIndex];
    [self.collectionView reloadData];
}

// 尾部加载更多数据
- (void)realoadAppendData {
    if (self.decreasingStep == 0) {
        return;
    }
    NSInteger cellCount = self.layout.cellCount;
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint offset = self.collectionView.contentOffset;
        if (cellCount < self.layout.cellCount) {
            offset.y += self.maxItemSize.height;
        }
        offset = [self.layout targetContentOffsetForProposedContentOffset:offset withScrollingVelocity:CGPointZero];
        [self.collectionView setContentOffset:offset animated:YES];
    });
}

- (void)reloadData {
    [self.collectionView reloadData];
    
    if (self.decreasingStep != 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint offset = [self.layout targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset withScrollingVelocity:CGPointZero];
            [self.collectionView setContentOffset:offset animated:NO];
        });
    }
}

- (void)reloadDataForDelete:(BOOL)success {
    self.collectionView.scrollEnabled = YES;
    self.longGesture.enabled = YES;
    self.dragCell.hidden = NO;
    self.dragCell = nil;
    self.longPressIndexPath = nil;
    
    if (self.decreasingStep != 0) {
        if (success) {
            CGFloat contentHeight = self.collectionView.contentSize.height;
            CGFloat offset = self.collectionView.contentOffset.y;
            CGFloat height = CGRectGetHeight(self.collectionView.frame);
            if (contentHeight - offset - height < self.maxItemSize.height) {
                offset -= self.maxItemSize.height;
                [self.collectionView setContentOffset:CGPointMake(0, offset)];
            }
        }
    }
    
    [self reloadData];
}

#pragma mark - 上下拉刷新
- (void)setHeaderRefreshView:(UIView<DRTimeFlowViewRefreshViewProtocol> *)headerRefreshView {
    if (self.decreasingStep == 0) {
        return;
    }
    self.layout.headerRefreshView = headerRefreshView;
}

- (void)endHeaderRefreshing {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusNormal];
}

- (void)endHeaderRefreshingWithNoMoreData {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusNoMoreData];
}

- (void)headerRefreshRest {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusRest];
}

- (void)setFooterRefreshView:(UIView<DRTimeFlowViewRefreshViewProtocol> *)footerRefreshView {
    if (self.decreasingStep == 0) {
        return;
    }
    self.layout.footerRefreshView = footerRefreshView;
}

- (void)endFooterRefreshing {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusNormal];
}

- (void)endFooterRefreshingWithNoMoreData {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusNoMoreData];
}

- (void)footerRefreshRest {
    if (self.decreasingStep == 0) {
        return;
    }
    [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusRest];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfRowsInTimeFlowView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource timeFlowView:self cellForRowAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldSelectRowAtIndex:)]) {
        return [self.delegate timeFlowView:self shouldSelectRowAtIndex:indexPath.row];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    CGAffineTransform oldTrans = cell.transform;
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformScale(oldTrans, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = oldTrans;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(timeFlowView:didSelectRowAtIndex:)]) {
                [self.delegate timeFlowView:self didSelectRowAtIndex:indexPath.row];
            }
        }];
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldDeselectRowAtIndex:)]) {
        [self.delegate timeFlowView:self shouldDeselectRowAtIndex:indexPath.row];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didDeselectRowAtIndex:)]) {
        [self.delegate timeFlowView:self didDeselectRowAtIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (cell.layer.cornerRadius != self.cellCornerRadius) {
        cell.clipsToBounds = NO;
        cell.layer.cornerRadius = self.cellCornerRadius;
        cell.layer.borderColor = cell.backgroundColor.CGColor;
        cell.layer.borderWidth = 1;
    }
    if (self.cellShadowColor) {
        if (!cell.shadowLayer) {
            [cell addShadowLayerWithShadowColor:self.cellShadowColor
                                         offset:self.coverOffset + self.cellShadowOffset
                                   cornerRadius:self.cellCornerRadius];
        } else {
            cell.shadowColor = self.cellShadowColor;
        }
    }
    [self.visibleCellsMap safeSetObject:cell forKey:@(indexPath.row)];
    [self setupVisibleCells];
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willDisplayCell:forRowAtIndex:)]) {
        [self.delegate timeFlowView:self willDisplayCell:cell forRowAtIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.maxItemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -self.coverOffset;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.decreasingStep != 0) {
        if (!self.haveDrag) {
            CGFloat minOffset = self.maxItemSize.height - CGRectGetHeight(scrollView.frame);
            if (scrollView.contentOffset.y < minOffset && scrollView.contentSize.height > 0) {
                scrollView.contentOffset = CGPointMake(0, minOffset);
                [self setupVisibleCells];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScroll:)]) {
        [self.delegate timeFlowView:self didScroll:scrollView];
    }
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScrollToBottom:)]) {
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat bottomRest = contentHeight - scrollView.contentOffset.y - scrollView.height;
        if (bottomRest <= -[self.layout.footerRefreshView refreshViewHeight]) {
            [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusPrepared];
        } else {
            [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusNormal];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScrollToTop:)]) {
        if (self.collectionView.contentOffset.y <= -self.collectionView.height) {
            [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusPrepared];
        } else {
            [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusNormal];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.haveDrag = YES;
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willBeginDragging:)]) {
        [self.delegate timeFlowView:self willBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate timeFlowView:self willEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (self.decreasingStep != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupVisibleCells];
            });
        }
    }
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndDragging:willDecelerate:)]) {
        [self.delegate timeFlowView:self didEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:willBeginDecelerating:)]) {
        [self.delegate timeFlowView:self willBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupVisibleCells];
    });
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didEndDecelerating:)]) {
        [self.delegate timeFlowView:self didEndDecelerating:scrollView];
    }
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScrollToBottom:)]) {
        if (self.layout.footerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusPrepared) {
            [self.layout.footerRefreshView setStatus:DRTimeFlowPullRefreshStatusLoading];
            [self.delegate timeFlowView:self didScrollToBottom:scrollView];
        }
    }
    if ([self.delegate respondsToSelector:@selector(timeFlowView:didScrollToTop:)]) {
        if (self.layout.headerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusPrepared) {
            [self.layout.headerRefreshView setStatus:DRTimeFlowPullRefreshStatusLoading];
            [self.delegate timeFlowView:self didScrollToTop:scrollView];
        }
    }
    self.haveDrag = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.decreasingStep != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupVisibleCells];
        });
    }
}

#pragma mark - private
- (void)setupVisibleCells {
    if (self.decreasingStep == 0) {
        return;
    }
    UICollectionViewCell *lastCell;
    for (NSNumber *index in self.layout.visibleIndexs) {
        lastCell = self.visibleCellsMap[index];
        lastCell.shadowLayer.hidden = NO;
        [lastCell.superview bringSubviewToFront:lastCell];
    }
    lastCell.shadowLayer.hidden = YES;
}

#pragma mark - long press to delete
- (void)onLongPressGestureStateChange:(UILongPressGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:onLongPressGestureStateChange:longPressGesture:)]) {
        [self.delegate timeFlowView:self onLongPressGestureStateChange:sender.state longPressGesture:sender];
    }
    
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (sender.state == UIGestureRecognizerStateBegan) { // 长按手势开始
        if (indexPath) {
            [self onLongPressBeganWithSender:sender indexPath:indexPath];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged){ // 手指移动
        [self onLongPressMove:sender];
    } else { // 长按结束
        [self onLongPressEnd:sender];
    }
}

- (void)onLongPressBeganWithSender:(UILongPressGestureRecognizer *)sender indexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:isDragging:)]) {
        [self.delegate timeFlowView:self isDragging:YES];
    }
    self.longPressIndexPath = indexPath;
    BOOL canDelete = YES;
    if ([self.delegate respondsToSelector:@selector(timeFlowView:shouldDeleteRowAtIndex:)]) {
        canDelete = [self.delegate timeFlowView:self shouldDeleteRowAtIndex:indexPath.row];
    }
    if (canDelete) {
        if ([self.delegate respondsToSelector:@selector(timeFlowView:willDeleteRowAtIndex:)]) {
            [self.delegate timeFlowView:self willDeleteRowAtIndex:self.longPressIndexPath.row];
        }
        
        [kDRWindow addSubview:self.deleteView];
        [self.deleteView show];
    }
    
    // 获取长按的cell
    UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:self.longPressIndexPath];
    CGAffineTransform transform = attr.transform;
    self.dragCell = [self.collectionView cellForItemAtIndexPath:self.longPressIndexPath];
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        // 先动画让cell变回正常大小
        self.dragCell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        if (sender.state != UIGestureRecognizerStateEnded &&
            sender.state != UIGestureRecognizerStateCancelled &&
            sender.state != UIGestureRecognizerStateFailed &&
            sender.state != UIGestureRecognizerStatePossible) {
            // 隐藏阴影图层
            self.dragCell.shadowLayer.hidden = YES;
            if (self.longPressIndexPath.row > 0) {
                UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.longPressIndexPath.row-1 inSection:0]];
                lastCell.shadowLayer.hidden = YES;
            }
            // 创建一个imageView并添加到window，imageView的image由cell截图得来
            self.dragImageView = [self createCellImageView];
            // 使用手指的中心位置设置截图中心点
            self.dragImageView.center =  [sender locationInView:kDRWindow];
            // 隐藏并恢复cell大小
            self.dragCell.hidden = YES;
            self.dragCell.transform = transform;
        } else {
            [self.collectionView reloadData];
        }
    }];
}

- (void)onLongPressMove:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:kDRWindow];
    self.dragImageView.center = point;
    
    // 判断拖动的cell的中心是否在删除区域
    BOOL inDeleteView = CGRectContainsPoint(self.deleteView.frame, point);
    CGAffineTransform trans = CGAffineTransformIdentity;
    if(inDeleteView) {
        trans = CGAffineTransformMakeScale(0.4, 0.4);
    }
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.dragImageView.transform = trans;
    } completion:^(BOOL finished) {
        [self.deleteView backgroundAnimationWithIsZoom:inDeleteView];
    }];
}

- (void)onLongPressEnd:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:kDRWindow];
    BOOL delete = CGRectContainsPoint(self.deleteView.frame, point);
    kDRWeakSelf
    [self.deleteView dismissComplete:^{
        if ([weakSelf.delegate respondsToSelector:@selector(timeFlowView:isDragging:)]) {
            [weakSelf.delegate timeFlowView:weakSelf isDragging:NO];
        }
    }];
    
    if (delete) {
        // 移除截图视图
        [UIView animateWithDuration:kDRAnimationDuration animations:^{
            self.dragImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.dragImageView removeFromSuperview];
            self.dragImageView = nil;
        }];
        
        // 删除期间禁用滚动和长按手势
        self.collectionView.scrollEnabled = NO;
        self.longGesture.enabled = NO;
        
        kDRWeakSelf
        [self.delegate timeFlowView:self beginDeleteRowAtIndex:self.longPressIndexPath.row whenComplete:^(BOOL deleteSuccess) {
            [weakSelf reloadDataForDelete:deleteSuccess];
        }];
    } else {
        [self recoverDragView];
    }
}

- (UIImageView *)createCellImageView {
    if (CGRectIsEmpty(self.dragCell.frame)) {
        return nil;
    }
    
    UIImageView *cellImageView = [[UIImageView alloc] initWithImage:[UIImage imageFromView:self.dragCell]];
    cellImageView.layer.shadowRadius = self.cellShadowOffset;
    cellImageView.layer.shadowOpacity = 1.0;
    cellImageView.layer.shadowColor = self.cellShadowColor.CGColor;
    [kDRWindow addSubview:cellImageView];
    return cellImageView;
}

// 恢复cell显示，移除cellImageView
- (void)recoverDragView {
    if ([self.delegate respondsToSelector:@selector(timeFlowView:cancelDeleteRowAtIndex:)]) {
        [self.delegate timeFlowView:self cancelDeleteRowAtIndex:self.longPressIndexPath.row];
    }
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.dragImageView.transform = self.dragCell.transform;
        self.dragImageView.center = [self.dragCell.superview convertPoint:self.dragCell.center
                                                                   toView:kDRWindow];
    } completion:^(BOOL finished) {
        self.dragCell.hidden = NO;
        self.dragCell = nil;
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.longPressIndexPath = nil;
    }];
    [self setupVisibleCells];
}

#pragma mark - lazy load
// 垃圾桶视图
- (DRSectorDeleteView *)deleteView {
    static DRSectorDeleteView *deleteV = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deleteV = [DRSectorDeleteView new];
    });
    return deleteV;
}

- (NSMutableDictionary<NSNumber *, UICollectionViewCell *> *)visibleCellsMap {
    if (!_visibleCellsMap) {
        _visibleCellsMap = [NSMutableDictionary dictionary];
    }
    return _visibleCellsMap;
}

#pragma mark - lifecycle
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (!self.collectionView) {
        self.layout = [[DRTimeFlowLayout alloc] init];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_offset(0);
        }];
        self.collectionView = collectionView;
        
        self.maxItemSize = CGSizeMake(kDRScreenWidth-56, 74);
        self.decreasingStep = 4;
        self.coverOffset = 4;
        self.cellCornerRadius = 4;
        self.cellShadowColor = [UIColor hx_colorWithHexRGBAString:@"D6E7F4"];
        self.cellShadowOffset = 20;
    }
}

- (void)dealloc {
    kDR_LOG(@"%@dealloc", NSStringFromClass([self class]));
}

@end
