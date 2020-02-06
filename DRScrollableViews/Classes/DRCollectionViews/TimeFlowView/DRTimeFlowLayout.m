//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <DRCategories/NSArray+DRExtension.h>

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat height;               // collectionView Height
@property (nonatomic, assign) CGFloat maxCellHeight;        // cell最大高度
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数
@property (nonatomic, assign) CGFloat cellContentHeight; // 所有cell都显示最大时的高度

@property (nonatomic, assign) BOOL needScroll;
@property (nonatomic, assign) NSInteger scrollTargetIndex;
@property (nonatomic, assign) BOOL needHide;
@property (nonatomic, assign) NSInteger hideTargetIndex;

@end

@implementation DRTimeFlowLayout

- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex {
    self.needScroll = YES;
    self.scrollTargetIndex = bottomIndex;
}

- (void)reloadDataScrollToBottomIndex:(NSInteger)bottomIndex hideIndex:(NSInteger)hideIndex {
    self.needScroll = YES;
    self.scrollTargetIndex = bottomIndex;
    self.needHide = YES;
    self.hideTargetIndex = hideIndex;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.maxCellHeight = self.maxItemSize.height;
    self.height = CGRectGetHeight(self.collectionView.bounds);
}

- (CGSize)collectionViewContentSize {
    // 获取当前cell总数，并计算内容大小
    _cellCount = [self.collectionView numberOfItemsInSection:0];
    _cellContentHeight = self.maxCellHeight;
    if (_cellCount > 0) {
        _cellContentHeight = self.cellCount * self.maxCellHeight;
    }
    
    // 设置顶部inset，保证所有cell都能滚动到最大位置
    self.collectionView.contentInset = UIEdgeInsetsMake(self.height, 0, self.maxCellHeight, 0);
    
    // 设置偏移
    if (self.needScroll) {
        CGFloat offset = self.cellContentHeight - self.height;
        if (self.scrollTargetIndex < self.cellCount-1) { // 不是最后一条
            NSInteger bottomOutSideCount = self.cellCount - self.scrollTargetIndex -1;
            offset -= bottomOutSideCount * self.maxItemSize.height;
        }
        [self.collectionView setContentOffset:CGPointMake(0, offset)];
        self.needScroll = NO;
    }

    CGFloat widtdh = CGRectGetWidth(self.collectionView.frame);
    [self setupRefreshViewsWithWidth:widtdh];
    
    // 可滚动区域大小设置的大一点
    return CGSizeMake(widtdh, self.cellContentHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.cellCount == 0) {
        return @[];
    }
    
    // 获取最底部可见cell的序号
    CGFloat contentOffsetY = self.collectionView.contentOffset.y; // 当前滚动偏移量
    CGFloat bottomOutSideHeight = self.cellContentHeight - contentOffsetY - self.height;
    NSInteger bottomOutSideCount = 0;
    if (bottomOutSideHeight > 0) {
        bottomOutSideCount = bottomOutSideHeight / self.maxCellHeight;
    }
    NSInteger lastVisibleIndex = self.cellCount - bottomOutSideCount - 1; // 最后一个可见cell的序号
    if (lastVisibleIndex < 0) { // 全部滚出collectionView外
        return @[];
    }
    
    // 从底部开始计算缩放，及设置坐标
    CGFloat bottomCellBottomY; // 最底部可见cell的底坐标
    CGFloat bottomCellsHeight = 0; // 在底部CollectionView外的完整cell总高度
    if (bottomOutSideCount < 1) {
        bottomCellBottomY = self.cellContentHeight;
    } else {
        bottomCellsHeight = bottomOutSideCount * self.maxCellHeight;
        bottomCellBottomY = self.cellContentHeight - bottomCellsHeight;
    }
    
    CGFloat layoutHeight = 0; // 完成布局计算的高度，即可见cell的总高度
    CGFloat rate = 0.0; // 偏移导致的缩小比例
    CGFloat bottomCellVisibleHeight = 0.0;
    if (bottomOutSideHeight > 0) {
        bottomCellVisibleHeight = self.maxCellHeight - (bottomOutSideHeight - bottomCellsHeight);
        layoutHeight = bottomCellVisibleHeight;
        if (bottomCellVisibleHeight > self.coverOffset) {
            rate = (bottomCellVisibleHeight-self.coverOffset) / (self.maxCellHeight-self.coverOffset);
        }
    } else {
        layoutHeight = -bottomOutSideHeight;
    }
    
    NSInteger layoutIndex = lastVisibleIndex;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray<NSNumber *> *indexs = [NSMutableArray array];
    CGFloat wholeHeight = self.height + self.maxCellHeight; // 顶部多欲布局一个cell
    while (layoutHeight <= wholeHeight) {
        CGFloat cellHeight = self.maxCellHeight - self.decreasingStep * rate * (layoutIndex < lastVisibleIndex) - self.decreasingStep * (lastVisibleIndex - layoutIndex - (layoutIndex < lastVisibleIndex && bottomOutSideHeight > 0));
        if (cellHeight < 0) {
            break;
        }
        
        CGFloat scale = cellHeight / self.maxCellHeight;
        CGFloat cellCenterY = bottomCellBottomY - cellHeight / 2;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:layoutIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.maxItemSize;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.frame)/2, cellCenterY);
        if (self.needHide && layoutIndex == self.hideTargetIndex) {
            attributes.alpha = 0.0;
            self.needHide = NO;
        }
        [array safeInsertObject:attributes atIndex:0];
        [indexs safeInsertObject:@(layoutIndex) atIndex:0];
        
        bottomCellBottomY -= cellHeight;
        if (layoutIndex == lastVisibleIndex) {
            if (bottomCellVisibleHeight > 0 && bottomCellVisibleHeight < self.coverOffset) {
                bottomCellBottomY += bottomCellVisibleHeight;
            } else {
                bottomCellBottomY += self.coverOffset;
            }
        } else {
            bottomCellBottomY += self.coverOffset;
        }
        
        if (layoutIndex < lastVisibleIndex) {
            layoutHeight += cellHeight;
            if (bottomCellVisibleHeight > 0 && bottomCellVisibleHeight < self.coverOffset) {
                layoutHeight -= bottomCellVisibleHeight;
            } else {
                layoutHeight -= self.coverOffset;
            }
        }
        
        layoutIndex--;
        if (layoutIndex < 0) {
            break;
        }
    }
    _visibleIndexs = indexs;
    return array;
}

// 保持顶部最小cell，保持minVisibleHeight
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (proposedContentOffset.y < self.maxCellHeight - self.height) { // 第一条在collectionView外
        proposedContentOffset.y = self.maxCellHeight - self.height;
        if (self.headerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusPrepared ||
            self.headerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusLoading) {
            proposedContentOffset.y = -self.height;
        }
    } else {
        CGFloat bottomOutSideHeight = self.cellContentHeight - proposedContentOffset.y - self.height;
        if (bottomOutSideHeight > 0) {
            NSInteger bottomOutSideCount = bottomOutSideHeight / self.maxCellHeight;
            CGFloat bottomCellsHeight = 0;
            if (bottomOutSideCount > 0) {
                bottomCellsHeight = bottomOutSideCount * self.maxCellHeight;
            }
            CGFloat bottomCellVisibleHeight = self.maxCellHeight - (bottomOutSideHeight - bottomCellsHeight);
            if (bottomCellVisibleHeight > self.maxCellHeight / 2) {
                proposedContentOffset.y += (self.maxCellHeight - bottomCellVisibleHeight);
            } else {
                proposedContentOffset.y -= bottomCellVisibleHeight;
            }
        } else if (bottomOutSideHeight < 0) {
            proposedContentOffset.y += bottomOutSideHeight;
            if (self.footerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusPrepared ||
                self.footerRefreshView.currentStatus == DRTimeFlowPullRefreshStatusLoading) {
                proposedContentOffset.y += [self.headerRefreshView refreshViewHeight];
            }
        }
    }
    return proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

#pragma mark - private
- (void)setupRefreshViewsWithWidth:(CGFloat)width {
    if (self.headerRefreshView != nil) {
        if (self.headerRefreshView.superview == nil) {
            [self.collectionView addSubview:self.headerRefreshView];
        }
        CGFloat refreshViewHeight = [self.headerRefreshView refreshViewHeight];
        self.headerRefreshView.frame = CGRectMake(0, -self.height, width, refreshViewHeight);
    }
    
    if (self.footerRefreshView != nil) {
        if (self.footerRefreshView.superview == nil) {
            [self.collectionView addSubview:self.footerRefreshView];
        }
        CGFloat refreshViewHeight = [self.footerRefreshView refreshViewHeight];
        self.footerRefreshView.frame = CGRectMake(0, self.cellContentHeight, width, refreshViewHeight);
    }
}

@end
