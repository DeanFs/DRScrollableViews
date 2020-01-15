//
//  DRDragSortTableView.m
//  Records
//
//  Created by 冯生伟 on 2018/9/26.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "DRDragSortTableView.h"
#import "DRSectorDeleteView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <DRMacroDefines/DRMacroDefines.h>
#import <DRCategories/NSDictionary+DRExtension.h>
#import <DRCategories/UIImage+DRExtension.h>
#import <DRCategories/UIView+DRExtension.h>

typedef NS_ENUM(NSInteger, AutoScroll) {
    AutoScrollUp,
    AutoScrollDown
};

@interface DRDragSortTableView ()

@property (nonatomic, strong) NSIndexPath *startIndexPath;
@property (nonatomic, strong) NSIndexPath *fromIndexPath;
@property (nonatomic, strong) NSIndexPath *toIndexPath;
@property (nonatomic, strong) UIImageView *dragImageView; // 拖拽的视图的截图
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) AutoScroll autoScroll;
@property (nonatomic, strong) NSMutableDictionary *canSortCache;

@property (nonatomic, assign) BOOL dragBegan; // 开始拖拽
@property (nonatomic, assign) BOOL canUseSort; // 是否可以使用拖动排序功能
@property (nonatomic, assign) BOOL canUseDelete; // 是否可以使用拖动删除功能
@property (nonatomic, assign) BOOL canDeleteStartCell; // 当前吸起的cell是否可删除
@property (nonatomic, assign) CGRect tableRectInWindow; // tableView相对keyWindow的frame
@property (nonatomic, weak) UITableViewCell<DRDragSortCellDelegate> *dragCell; // 长按手势开始时的cell
@property (weak, nonatomic) UIView *dragView; // 长按后拖拽的视图(截图来源)
@property (assign, nonatomic) CGFloat topY;
@property (assign, nonatomic) CGFloat bottomY;

@end

@implementation DRDragSortTableView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.tableRectInWindow = [self.superview convertRect:self.frame toView:kDRWindow];
}

- (void)dealloc {
#ifdef DEBUG
    kDR_LOG(@"%@ dealloc", NSStringFromClass([self class]));
#endif
}

- (void)setDr_dragSortDelegate:(id<DRDragSortTableViewDelegate, UITableViewDelegate, UITableViewDataSource>)dragSortDelegate {
    _dr_dragSortDelegate = dragSortDelegate;
    
    self.delegate = dragSortDelegate;
    self.dataSource = dragSortDelegate;
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    
    self.canSortCache = [NSMutableDictionary dictionary];
    self.canUseSort = [dragSortDelegate respondsToSelector:@selector(dragSortTableView:canSortAtIndexPath:fromIndexPath:)];
    if (self.canUseSort) {
        // 设置默认滚动速度为4
        if (!_scrollSpeed) {
            _scrollSpeed = 4;
        }
    }
    
    self.canUseDelete = [dragSortDelegate respondsToSelector:@selector(dragSortTableView:canDeleteAtIndexPath:)];
    if (self.canUseDelete) {
        // 设置拖入删除区的缩放比
        if (!_willDeleteCellFrameScale) {
            _willDeleteCellFrameScale = 0.5;
        }
    }
    
    if (self.canUseDelete || self.canUseSort) {
        // 设置默认吸起的视图截图的缩放比例1.05
        if (!_cellFrameScale) {
            _cellFrameScale = 1.05;
        }
    }
    
    // 给tableView添加手势
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGestureStateChange:)]];
}

- (void)setStartIndexPath:(NSIndexPath *)startIndexPath {
    _startIndexPath = startIndexPath;
    _canDeleteStartCell = [self canDeleteAtStartIndexPath];
}

#pragma mark - Long Press Gesture Action
- (void)onLongPressGestureStateChange:(UILongPressGestureRecognizer *)sender {
    if (!self.canUseSort && !self.canUseDelete) {
        // 既不能拖动排序，也不能拖动删除
        return;
    }
    
    // 当前手指所在的cell的indexPath
    CGPoint point = [sender locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
    
    // 当前cell是否支持拖动排序
    NSNumber *canSortN = self.canSortCache[indexPath];
    BOOL canSort;
    if (canSortN) {
        canSort = canSortN.boolValue;
    } else {
        canSort = [self canSortWithIndex:indexPath fromIndexPath:self.fromIndexPath?:indexPath];
        [self.canSortCache safeSetObject:@(canSort) forKey:indexPath];
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) { // 长按手势开始
        if (![self canReactLongPressAtIndexPath:indexPath point:point]) {
            return;
        }
        self.startIndexPath = indexPath;
        // 既不能拖动排序，也不能拖动删除
        if (!canSort && !self.canDeleteStartCell) {
            return;
        }
        self.dragBegan = YES;
        
        [self onLongPressBeganWithSender:sender canSort:canSort];
    } else if (sender.state == UIGestureRecognizerStateChanged){ // 手指移动
        // 没有触发开始拖拽
        if (!self.dragBegan) {
            return;
        }
        [self onLongPressMove:sender canSort:canSort indexPath:indexPath];
    } else { // 长按结束
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableViewDragEnd:indexPath:)]) {
            [self.dr_dragSortDelegate dragSortTableViewDragEnd:self indexPath:indexPath];
        }
        // 没有触发开始拖拽
        if (!self.dragBegan) {
            [self.canSortCache removeAllObjects];
            return;
        }
        self.dragBegan = NO;
        // 既不能拖动排序，也不能拖动删除
        if (!self.fromIndexPath && !self.canDeleteStartCell) {
            [self.canSortCache removeAllObjects];
            return;
        }
        [self onLongPressEnd:sender];
    }
}

// 长按手势开始
- (void)onLongPressBeganWithSender:(UILongPressGestureRecognizer *)sender canSort:(BOOL)canSort {
    AudioServicesPlaySystemSound(1519); // 振动反馈
    
    if (self.canDeleteStartCell) { // 显示右下角删除区
        [kDRWindow addSubview:self.deleteView];
        [self.deleteView show];
    }
    
    if (canSort) {
        self.fromIndexPath = self.startIndexPath;
    }
    
    // 创建一个imageView，imageView的image由cell渲染得来
    self.dragImageView = [self createCellImageView];
    if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableViewDragBegan:indexPath:dragView:)]) {
        [self.dr_dragSortDelegate dragSortTableViewDragBegan:self
                                                   indexPath:self.startIndexPath
                                                    dragView:self.dragImageView];
    }
    self.dragImageView.alpha = 0.0;
    [self updateCellImageCenterWithPoint:[self.dragView.superview convertPoint:self.dragView.center
                                                                        toView:kDRWindow]];
    
    // 更改imageView的中心点为手指点击位置
    CGPoint imageCenter = [sender locationInView:kDRWindow];
    [UIView animateWithDuration:0.25 animations:^{
        [self updateCellImageCenterWithPoint:imageCenter];
        self.dragImageView.transform = CGAffineTransformMakeScale(self.cellFrameScale, self.cellFrameScale);
        self.dragImageView.alpha = 1;
        self.dragCell.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (sender.state != UIGestureRecognizerStateEnded &&
            sender.state != UIGestureRecognizerStateCancelled &&
            sender.state != UIGestureRecognizerStateFailed &&
            sender.state != UIGestureRecognizerStatePossible) {
            self.dragCell.hidden = YES;
        }
    }];
}

- (void)onLongPressMove:(UILongPressGestureRecognizer *)sender
                canSort:(BOOL)canSort
              indexPath:(NSIndexPath *)indexPath {
    CGPoint point = [sender locationInView:kDRWindow];
    [self updateCellImageCenterWithPoint:point];
    
    if (self.canDeleteStartCell) { // 可以删除
        // 判断拖动的cell的中心是否在删除区域
        BOOL inDeleteView = CGRectContainsPoint(self.deleteView.frame, point);
        CGAffineTransform trans = CGAffineTransformMakeScale(self.cellFrameScale, self.cellFrameScale);
        
        if(inDeleteView) {
            trans = CGAffineTransformMakeScale(self.willDeleteCellFrameScale, self.willDeleteCellFrameScale);
        }
        
        [UIView animateWithDuration:kDRAnimationDuration animations:^{
            self.dragImageView.transform = trans;
        } completion:^(BOOL finished) {
            [self.deleteView backgroundAnimationWithIsZoom:inDeleteView];
        }];
    }
    
    if (canSort && self.fromIndexPath) { // 可交换排序
        // 根据手势的位置，获取手指移动到的cell的indexPath
        self.toIndexPath = indexPath;
        
        // 判断cell是否被拖拽到了tableView的边缘，如果是，则自动滚动tableView
        if ([self isMoveToEdgeWithPonit:point] && self.toIndexPath) {
            [self startTimerToScrollTableView];
            return;
        } else {
            [self.displayLink invalidate];
        }
        
        [self exchangeCell];
    }
}

- (void)onLongPressEnd:(UILongPressGestureRecognizer *)sender {
    BOOL delete = NO;
    if (self.canDeleteStartCell) { // 可删除
        CGPoint point = [sender locationInView:kDRWindow];
        delete = CGRectContainsPoint(self.deleteView.frame, point);
        [self.deleteView dismiss];
    }
    
    NSIndexPath *toIndex;
    if (self.fromIndexPath) { // 可拖动排序
        [self.displayLink invalidate];
        
        toIndex = self.toIndexPath;
        if (!toIndex) {
            toIndex = self.fromIndexPath;
        }
    }
    
    if (delete) {
        [UIView animateWithDuration:0.25 animations:^{
            self.dragImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.dragImageView removeFromSuperview];
            self.dragImageView = nil;
        }];
        
        // 执行删除回调
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableView:deleteAtIndexPath:deleteDoneBlock:)]) {
            NSIndexPath *deleteIndex = self.startIndexPath;
            if (toIndex) {
                deleteIndex = toIndex;
            }
            kDRWeakSelf
            [self.dr_dragSortDelegate dragSortTableView:self deleteAtIndexPath:deleteIndex deleteDoneBlock:^{
                // 恢复cell显示
                weakSelf.dragCell.alpha = 1;
                weakSelf.dragCell.hidden = NO;
                weakSelf.dragCell = nil;
                [weakSelf sendSubviewToBack:weakSelf.dragCell];
            }];
        }
    } else {
        // 恢复cell显示
        [self recoverDragView];
        
        // 执行拖动排序完成回调
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableView:finishFromIndexPath:toIndexPath:)]) {
            [self.dr_dragSortDelegate dragSortTableView:self
                                 finishFromIndexPath:self.startIndexPath
                                         toIndexPath:toIndex];
        }
    }
    
    // 清空数据
    self.startIndexPath = nil;
    self.fromIndexPath = nil;
    self.toIndexPath = nil;
    [self.canSortCache removeAllObjects];
}


#pragma mark - UI Action
- (void)exchangeCell {
    if (self.toIndexPath && ![self.toIndexPath isEqual:self.fromIndexPath]) {
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableView:exchangeIndexPath:toIndexPath:)]) {
            [self.dr_dragSortDelegate dragSortTableView:self exchangeIndexPath:self.fromIndexPath toIndexPath:self.toIndexPath];
        }
        [self moveRowAtIndexPath:self.fromIndexPath toIndexPath:self.toIndexPath];
        self.fromIndexPath = self.toIndexPath;
    }
}

// 恢复cell显示，移除cellImageView
- (void)recoverDragView {
    self.dragCell.hidden = NO;
    self.dragCell.alpha = 0;
    [self sendSubviewToBack:self.dragCell];
    [UIView animateWithDuration:0.25 animations:^{
        self.dragCell.alpha = 1;
        self.dragImageView.alpha = 0;
        self.dragImageView.transform = CGAffineTransformIdentity;
        [self updateCellImageCenterWithPoint:[self.dragView.superview convertPoint:self.dragView.center
                                                                            toView:kDRWindow]];
    } completion:^(BOOL finished) {
        [self.dragImageView removeFromSuperview];
        self.dragImageView = nil;
        self.dragCell = nil;
    }];
}

- (void)updateCellImageCenterWithPoint:(CGPoint)point {
    self.dragImageView.center = point;
    if ([self isMoveToEdgeWithPonit:point]) {
        if (self.autoScroll == AutoScrollUp) {
            point.y = self.topY + self.dragImageView.height / 2;
        } else {
            point.y = self.bottomY - self.dragImageView.height / 2;
        }
    }
    if (!self.canDeleteStartCell) { // 不可删除时，只能纵向拖拽
        point.x = self.bounds.size.width/2;
    }
    self.dragImageView.center = point;
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

#pragma mark - util
- (UIImageView *)createCellImageView {
    if (CGRectIsEmpty(self.dragView.frame)) {
        return nil;
    }
    
    UIImageView *cellImageView = [[UIImageView alloc] initWithImage:[UIImage imageFromView:self.dragView]];
    cellImageView.layer.shadowRadius = 5.0;
    cellImageView.layer.shadowOpacity = 0.4;
    cellImageView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    [kDRWindow addSubview:cellImageView];
    return cellImageView;
}

- (BOOL)canSortWithIndex:(NSIndexPath *)indexPath fromIndexPath:(NSIndexPath *)fromIndexPath {
    if (!indexPath) {
        return NO;
    }
    if (self.canUseSort) {
        return [self.dr_dragSortDelegate dragSortTableView:self canSortAtIndexPath:indexPath fromIndexPath:fromIndexPath];
    }
    return NO;
}

- (BOOL)canDeleteAtStartIndexPath {
    if (!self.startIndexPath) {
        return NO;
    }
    if (self.canUseDelete) {
        return [self.dr_dragSortDelegate dragSortTableView:self canDeleteAtIndexPath:self.startIndexPath];
    }
    return NO;
}

- (BOOL)canReactLongPressAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    if (indexPath == nil) {
        return NO;
    }
    
    BOOL canReact = YES;
    self.dragCell = (UITableViewCell<DRDragSortCellDelegate> *)[self cellForRowAtIndexPath:indexPath];
    self.dragView = self.dragCell;
    CGPoint cellPoint = [self convertPoint:point toView:self.dragView];
    if ([self.dragCell respondsToSelector:@selector(canReactLongPressSubRect)]) {
        CGRect cellReactRect = [self.dragCell canReactLongPressSubRect];
        canReact = CGRectContainsPoint(cellReactRect, cellPoint);
    }
    if (canReact) {
        if ([self.dragCell respondsToSelector:@selector(subDragViewFromCellInDragSortTableView:)]) {
            self.dragView = (UIView<DRDragSortCellDelegate> *)[self.dragCell subDragViewFromCellInDragSortTableView:self];
            canReact = CGRectContainsPoint(self.dragView.frame, cellPoint);
        }
    }
    
    return canReact;
}

#pragma mark - 拖拽到边缘自动滚动
- (BOOL)isMoveToEdgeWithPonit:(CGPoint)point {
    // tableView顶部还有数据未显示
    CGFloat insetTop = self.contentInset.top;
    if (@available(iOS 11.0, *)) {
        insetTop += self.adjustedContentInset.top;
    }
    BOOL moreDateOutTop = self.contentOffset.y > -insetTop;
    // 手指一动到了tableView的上边缘
    CGFloat topY = self.tableRectInWindow.origin.y + self.contentInset.top;
    if (@available(iOS 11.0, *)) {
        topY += self.adjustedContentInset.top;
    }
    CGPoint pointInTableView = [kDRWindow convertPoint:point toView:self];
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:pointInTableView];
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        topY += [self.delegate tableView:self heightForHeaderInSection:currentIndexPath.section];
    }
    self.topY = topY;
    BOOL reachTop = self.dragImageView.y <= topY;
    // 手指到达tableView上边缘且顶部有未显示的数据
    if (moreDateOutTop && reachTop) {
        self.autoScroll = AutoScrollUp;
        return YES;
    }
    
    // tableView底部还有数据未显示
    CGFloat visibleHeight = self.height - self.contentInset.top - self.contentInset.bottom;
    if (@available(iOS 11.0, *)) {
        visibleHeight -= (self.adjustedContentInset.top + self.adjustedContentInset.bottom);
    }
    BOOL moreDataOutBottom = self.contentSize.height - self.contentOffset.y > visibleHeight;
    // 手指到达tableView下边缘
    CGFloat dragImageViewBottom = self.dragImageView.y + self.dragImageView.height;
    CGFloat tableRectInWindowBottom = self.tableRectInWindow.origin.y + self.tableRectInWindow.size.height - self.contentInset.bottom;
    if (@available(iOS 11.0, *)) {
        tableRectInWindowBottom -= self.adjustedContentInset.bottom;
    }
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        tableRectInWindowBottom -= [self.delegate tableView:self heightForFooterInSection:currentIndexPath.section];
    }
    self.bottomY = tableRectInWindowBottom;
    BOOL reachBottom = dragImageViewBottom >= tableRectInWindowBottom;
    if (moreDataOutBottom && reachBottom) {
        self.autoScroll = AutoScrollDown;
        return YES;
    }
    return NO;
}

- (void)startTimerToScrollTableView {
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableView)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)scrollTableView {
    // 改变tableView的contentOffset，实现自动滚动
    CGFloat height = self.autoScroll == AutoScrollUp? -self.scrollSpeed : self.scrollSpeed;
    [self setContentOffset:CGPointMake(0, self.contentOffset.y + height)];
    
    // 滚动tableView的同时也要执行插入操作
    CGFloat x = self.bounds.size.width/2;
    CGFloat y;
    CGFloat halfCellHeight = self.dragView.bounds.size.height/2;
    if (self.autoScroll == AutoScrollUp) {
        y = self.contentInset.top + self.contentOffset.y + halfCellHeight;
    } else {
        y = self.contentInset.top + self.contentOffset.y + self.bounds.size.height - halfCellHeight;
    }
    CGPoint currentPoint = CGPointMake(x, y);
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentPoint];
    BOOL canSort = [self canSortWithIndex:indexPath fromIndexPath:self.fromIndexPath];
    
    if (!canSort) {
        [self.displayLink invalidate];
        return;
    }
    
    if (self.autoScroll == AutoScrollUp) { // 滚到最上面
        if (self.contentOffset.y <= -self.contentInset.top) {
            self.contentOffset = CGPointMake(0, -self.contentInset.top);
            [self.displayLink invalidate];
        }
    } else { // 滚到最下面
        if (self.contentOffset.y >= self.contentSize.height + self.contentInset.bottom - self.frame.size.height) {
            self.contentOffset = CGPointMake(0, self.contentSize.height + self.contentInset.bottom - self.frame.size.height);
            [self.displayLink invalidate];
        }
    }
    
    self.toIndexPath = indexPath;
    [self exchangeCell];
}

@end
