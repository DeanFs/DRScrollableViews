//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat height;               // collectionView Height
@property (nonatomic, assign) CGFloat maxCellHeight;        // cell最大高度
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数

@property (nonatomic, assign) BOOL needScroll;
@property (nonatomic, assign) NSInteger targetIndex;

@end

@implementation DRTimeFlowLayout

- (void)reloadDataScrollToIndex:(NSInteger)index {
    self.needScroll = YES;
    self.targetIndex = index;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self setupCount];
}

- (CGSize)collectionViewContentSize {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    if (cellCount == 0) {
        _cellCount = 0;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.collectionView.contentOffset = CGPointZero;
        return CGSizeZero;
    }
    // 设置顶部inset，保证所有cell都能滚动到最大位置
    self.collectionView.contentInset = UIEdgeInsetsMake(self.height - self.maxCellHeight, 0, 0, 0);
    
    // 获取当前cell总数，并计算内容大小
    self.cellCount = cellCount;
    _cellContentHeight = cellCount * self.maxCellHeight;
    
    // 设置偏移
    if (self.needScroll) {
        CGFloat offset = self.cellContentHeight - self.height;
        if (self.targetIndex < cellCount-1) { // 不是最后一条
            NSInteger bottomOutSideCount = cellCount - self.targetIndex -1;
            offset -= bottomOutSideCount * self.maxItemSize.height;
        }
        [self.collectionView setContentOffset:CGPointMake(0, offset)];
        self.needScroll = NO;
    }
    
    // 可滚动区域大小设置的大一点
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.cellContentHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.cellCount == 0) {
        return @[];
    }
    
    CGFloat contentOffsetY = self.collectionView.contentOffset.y; // 当前滚动偏移量
    // 计算顶部滚出collectionView的cell数量
    NSInteger topOutSideCount = 0;
    if (contentOffsetY > 0) {
        topOutSideCount = contentOffsetY / self.maxCellHeight;
    }
    
    // 计算底部未滚完的高度及cell数量
    CGFloat bottomOutSideHeight = self.cellContentHeight - contentOffsetY - self.height;
    NSInteger bottomOutSideCount = 0;
    if (bottomOutSideHeight > 0) {
        bottomOutSideCount = bottomOutSideHeight / self.maxCellHeight;
    }
    
    // 获取最底部可见cell的序号
    NSInteger currentVisibleCount = self.cellCount - topOutSideCount - bottomOutSideCount; // 当前可见cell数
    NSInteger lastVisibleIndex = topOutSideCount + currentVisibleCount - 1; // 最后一个可见cell的序号
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
    while (layoutHeight < self.height) {
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
        [array insertObject:attributes atIndex:0];
        [indexs insertObject:@(layoutIndex) atIndex:0];
        
        layoutIndex--;
        if (layoutIndex < 0) {
            break;
        }
        
        bottomCellBottomY -= cellHeight;
        layoutHeight += cellHeight;
        if (layoutIndex == lastVisibleIndex) {
            if (bottomCellVisibleHeight > 0 && bottomCellVisibleHeight < self.coverOffset) {
                bottomCellBottomY += bottomCellVisibleHeight;
                layoutHeight -= bottomCellVisibleHeight;
            } else {
                bottomCellBottomY += self.coverOffset;
                layoutHeight -= self.coverOffset;
            }
        } else {
            bottomCellBottomY += self.coverOffset;
            layoutHeight -= self.coverOffset;
        }
    }
    _visibleIndexs = indexs;
    return array;
}

// 保持顶部最小cell，保持minVisibleHeight
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
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
            proposedContentOffset.y -= (bottomCellVisibleHeight - self.coverOffset);
        }
    }    
    return proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

#pragma mark - private
- (void)setupCount {
    self.maxCellHeight = self.maxItemSize.height;
    self.height = CGRectGetHeight(self.collectionView.bounds);
}

@end
