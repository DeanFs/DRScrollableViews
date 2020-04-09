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
    AutoScrollUp,   // 手指到达下边缘，向上滚
    AutoScrollDown  // 到达上边缘，向下滚
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
@property (assign, nonatomic) BOOL canSortStartCell; // 当前吸起的cell是否可排序
@property (nonatomic, assign) CGRect tableRectInWindow; // tableView相对keyWindow的frame
@property (nonatomic, weak) UITableViewCell<DRDragSortCellDelegate> *dragCell; // 长按手势开始时的cell
@property (weak, nonatomic) UIView *dragView; // 长按后拖拽的视图(截图来源)
@property (assign, nonatomic) CGFloat maxCenterY;
@property (assign, nonatomic) CGFloat minCenterY;
@property (assign, nonatomic) CGFloat minOffsetY;
@property (assign, nonatomic) CGFloat maxOffsetY;

@end

@implementation DRDragSortTableView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.tableRectInWindow = [self.superview convertRect:self.frame toView:kDRWindow];
}

- (void)dealloc {
    kDR_LOG(@"%@ dealloc", NSStringFromClass([self class]));
}

- (void)setDr_dragSortDelegate:(id<DRDragSortTableViewDelegate>)dragSortDelegate {
    _dr_dragSortDelegate = dragSortDelegate;
    
    self.delegate = dragSortDelegate;
    self.dataSource = dragSortDelegate;
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    
    self.canSortCache = [NSMutableDictionary dictionary];
    self.canUseSort = [dragSortDelegate respondsToSelector:@selector(dragSortTableView:canSortAtIndexPath:fromIndexPath:)];
    if (self.canUseSort) {
        // 设置默认滚动速度为6
        if (!_scrollSpeed) {
            _scrollSpeed = 6;
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
        if (self.startIndexPath == nil) {
            self.canSortStartCell = canSort;
        }
    }
    
    // 边缘检测
    CGPoint pointToWindow = [sender locationInView:kDRWindow];
    BOOL isMoveToEdge = [self isMoveToEdgeWithPonitToWindow:pointToWindow
                                           pointInTableView:point];
    
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
        
        [self onLongPressBeganWithSender:sender
                                 canSort:canSort
                           pointToWindow:pointToWindow];
    } else if (sender.state == UIGestureRecognizerStateChanged){ // 手指移动
        // 没有触发开始拖拽
        if (!self.dragBegan) {
            return;
        }
        [self onLongPressMove:sender
                      canSort:canSort
                    indexPath:indexPath
                pointToWindow:pointToWindow
                 isMoveToEdge:isMoveToEdge];
    } else { // 长按结束
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableViewDragEnd:indexPath:)]) {
            [self.dr_dragSortDelegate dragSortTableViewDragEnd:self indexPath:indexPath];
        }
        // 没有触发开始拖拽
        if (!self.dragBegan) {
            self.startIndexPath = nil;
            self.fromIndexPath = nil;
            self.toIndexPath = nil;
            [self.canSortCache removeAllObjects];
            return;
        }
        self.dragBegan = NO;
        // 既不能拖动排序，也不能拖动删除
        if (!self.fromIndexPath && !self.canDeleteStartCell) {
            [self.canSortCache removeAllObjects];
            return;
        }
        [self onLongPressEnd:sender
               pointToWindow:pointToWindow];
    }
}

// 长按手势开始
- (void)onLongPressBeganWithSender:(UILongPressGestureRecognizer *)sender
                           canSort:(BOOL)canSort
                     pointToWindow:(CGPoint)pointToWindow {
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
    [UIView animateWithDuration:0.25 animations:^{
        [self updateCellImageCenterWithPoint:pointToWindow];
        self.dragImageView.transform = CGAffineTransformMakeScale(self.cellFrameScale, self.cellFrameScale);
        self.dragImageView.alpha = 1;
        self.dragCell.alpha = 0.0;
    } completion:^(BOOL finished) {
        // 防止相应准备过程中松手，导致cell隐藏
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
              indexPath:(NSIndexPath *)indexPath
          pointToWindow:(CGPoint)pointToWindow
           isMoveToEdge:(BOOL)isMoveToEdge {
    [self updateCellImageCenterWithPoint:pointToWindow];
    
    if (self.canDeleteStartCell) { // 可以删除
        // 判断拖动的cell的中心是否在删除区域
        BOOL inDeleteView = CGRectContainsPoint(self.deleteView.frame, pointToWindow);
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
    
    // 判断cell是否被拖拽到了tableView的边缘，如果是，则自动滚动tableView
    if (isMoveToEdge) {
        [self startTimerToScrollTableView];
        return;
    } else {
        [self stopTimer];
    }
    
    if (canSort && self.canSortStartCell && self.fromIndexPath) { // 可交换排序
        [self exchangeCellToIndexPath:indexPath];
    }
}

- (void)onLongPressEnd:(UILongPressGestureRecognizer *)sender
         pointToWindow:(CGPoint)ponitToWindow {
    BOOL delete = NO;
    if (self.canDeleteStartCell) { // 可删除
        delete = CGRectContainsPoint(self.deleteView.frame, ponitToWindow);
        [self.deleteView dismiss];
    }
    
    NSIndexPath *toIndex;
    if (self.fromIndexPath) { // 可拖动排序
        [self stopTimer];
        
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
// cell动画交换
- (void)exchangeCellToIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath && ![toIndexPath isEqual:self.fromIndexPath]) {
        BOOL succession = YES; // 两个cell中间连续
        BOOL betweenSections = NO;
        NSIndexPath *moveFromIndexPath = self.fromIndexPath; // 本次移动起点
        NSIndexPath *moveToIndexPath = toIndexPath; // 本次移动终点
        if (moveFromIndexPath.section == moveToIndexPath.section) {
            if (moveFromIndexPath.row > moveToIndexPath.row) {
                moveFromIndexPath = moveToIndexPath;
                moveToIndexPath = self.fromIndexPath;
            }
            succession = (moveToIndexPath.row - moveFromIndexPath.row == 1);
        } else {
            betweenSections = YES;
            if (moveFromIndexPath.section > moveToIndexPath.section) { // 从下往上跨组
                NSInteger cellCount = [self.dataSource tableView:self numberOfRowsInSection:moveToIndexPath.section];
                succession = (moveFromIndexPath.row == 0 && moveToIndexPath.row == cellCount - 1);
                if (succession) { // 交换
                    moveToIndexPath = [NSIndexPath indexPathForRow:cellCount inSection:moveToIndexPath.section];
                    toIndexPath = moveToIndexPath;
                }
            } else { // 从上往下
                NSInteger cellCount = [self.dataSource tableView:self numberOfRowsInSection:moveFromIndexPath.section];
                succession = (moveFromIndexPath.row == cellCount - 1 && moveToIndexPath.row == 0);
            }
        }
        
        if ([self.dr_dragSortDelegate respondsToSelector:@selector(dragSortTableView:exchangeIndexPath:toIndexPath:betweenSections:succession:)]) {
            [self.dr_dragSortDelegate dragSortTableView:self
                                      exchangeIndexPath:moveFromIndexPath
                                            toIndexPath:moveToIndexPath
                                        betweenSections:betweenSections
                                             succession:succession];
        }
        
        [self keepDragCellHidden];
        [self beginUpdates];
        [self moveRowAtIndexPath:moveFromIndexPath
                     toIndexPath:moveToIndexPath];
        if (!succession) {
            [self moveRowAtIndexPath:moveToIndexPath
                         toIndexPath:moveFromIndexPath];
        }
        [self endUpdates];
        
        NSArray<UITableViewCell *> *cells = [self visibleCells];
        for (UITableViewCell *cell in cells) {
            [self sendSubviewToBack:cell];
        }
        
        self.fromIndexPath = toIndexPath;
        self.toIndexPath = toIndexPath;
    }
}

// 恢复cell显示，移除cellImageView
- (void)recoverDragView {
    self.dragCell.hidden = NO;
    self.dragCell.alpha = 0;
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
    if (point.y < self.minCenterY) {
        point.y = self.minCenterY;
    } else if (point.y > self.maxCenterY) {
        point.y = self.maxCenterY;
    }
    if (!self.canDeleteStartCell) { // 不可删除时，只能纵向拖拽
        point.x = self.width / 2;
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

- (void)keepDragCellHidden {
    self.dragCell.hidden = YES;
    NSIndexPath *fromIndexPath = self.fromIndexPath;
    if (fromIndexPath == nil) {
        fromIndexPath = self.startIndexPath;
    }
    UITableViewCell<DRDragSortCellDelegate> *cell = (UITableViewCell<DRDragSortCellDelegate> *)[self cellForRowAtIndexPath:fromIndexPath];
    if (cell != self.dragCell) {
        self.dragCell.hidden = NO;
        self.dragCell = cell;
        self.dragView = cell;
        if ([self.dragCell respondsToSelector:@selector(subDragViewFromCellInDragSortTableView:)]) {
            self.dragView = (UIView<DRDragSortCellDelegate> *)[self.dragCell subDragViewFromCellInDragSortTableView:self];
        }
        self.dragCell.hidden = YES;
    }
}

#pragma mark - 拖拽到边缘自动滚动
- (BOOL)isMoveToEdgeWithPonitToWindow:(CGPoint)pointToWindow pointInTableView:(CGPoint)pointInTableView {
    CGFloat halfHeight = self.dragImageView.height / 2;
    CGFloat pointTop = pointToWindow.y - halfHeight;
    CGFloat pointBottom = pointToWindow.y + halfHeight;
    
    // 上边缘检查
    // 获取上边缘坐标
    CGFloat topY = self.tableRectInWindow.origin.y;
    self.minCenterY = topY + halfHeight;
    // 到达上边缘判断
    BOOL reachTop = pointTop <= topY;
    // 上边缘以上还有数据未显示
    CGFloat insetTop = 0;
    if (@available(iOS 11.0, *)) {
        insetTop += self.adjustedContentInset.top;
    } else {
        insetTop += self.contentInset.top;
    }
    self.minOffsetY = -insetTop;
    BOOL moreDataOutTop = self.contentOffset.y > -insetTop;
    // 手指到达tableView上边缘且顶部有未显示的数据
    if (moreDataOutTop && reachTop && self.canUseSort) {
        self.autoScroll = AutoScrollDown;
        return YES;
    }
    
    // 下边缘检查
    // 获取下边缘坐标
    CGFloat bottomY = self.tableRectInWindow.origin.y + self.height;
    self.maxCenterY = bottomY - halfHeight;
    // 到达下边缘判断
    BOOL reachBottom = pointBottom >= bottomY;
    // 下边缘以下还有数据未显示
    CGFloat insetBottom = 0;
    if (@available(iOS 11.0, *)) {
        insetBottom += self.adjustedContentInset.bottom;
    } else {
        insetBottom += self.contentInset.bottom;
    }
    CGFloat maxOffsetY = (self.contentSize.height + insetBottom) - self.height;
    self.maxOffsetY = maxOffsetY;
    BOOL moreDataOutBottom = (maxOffsetY > 0 && self.contentOffset.y < maxOffsetY);
    if (moreDataOutBottom && reachBottom && self.canUseSort) {
        // 手指到达tableView下边缘且顶部有未显示的数据
        self.autoScroll = AutoScrollUp;
        return YES;
    }
    return NO;
}

- (void)startTimerToScrollTableView {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableView)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)scrollTableView {
    // 改变tableView的contentOffset，实现自动滚动
    CGFloat height = self.autoScroll == AutoScrollUp? self.scrollSpeed : -self.scrollSpeed;
    [self setContentOffset:CGPointMake(0, self.contentOffset.y + height)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取滚动后，当前手指对应的indexPath
        CGPoint currentPoint = [kDRWindow convertPoint:self.dragImageView.center toView:self];
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:currentPoint];
        BOOL canSort = [self canSortWithIndex:indexPath fromIndexPath:self.fromIndexPath];
        if (canSort && self.canSortStartCell) {
            [self exchangeCellToIndexPath:indexPath];
        } else {
            [self keepDragCellHidden];
        }
        
        if (![self isMoveToEdgeWithPonitToWindow:self.dragImageView.center pointInTableView:currentPoint]) {
            [self stopTimer];
            if (self.autoScroll == AutoScrollUp) { // 往上滚
                if (self.contentOffset.y > self.maxOffsetY) {
                    self.contentOffset = CGPointMake(0, self.maxOffsetY);
                }
            } else { // 往下滚
                if (self.contentOffset.y < self.minOffsetY) {
                    self.contentOffset = CGPointMake(0, self.minOffsetY);
                }
            }
        }
    });
}

@end

