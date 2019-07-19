//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat height;               // collectionView Height
@property (nonatomic, assign) CGFloat cellContentHeight;  // 所有cell都显示最大时的高度
@property (nonatomic, assign) CGFloat maxCellHeight;        // cell最大高度
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数
@property (nonatomic, assign) BOOL firstLayout;             // 第一次加载

@end

@implementation DRTimeFlowLayout

/**
 实例化layout
 
 @param maxItemSize 最大的cell的size
 @param decreasingStep cell高度递减的值
 @param coverOffset 上一个cell被遮盖的高度值
 @return 实例
 */
+ (instancetype)timeFlowLayoutWithMaxtItemSize:(CGSize)maxItemSize
                                decreasingStep:(CGFloat)decreasingStep
                                   coverOffset:(CGFloat)coverOffset {
    DRTimeFlowLayout *layout = [DRTimeFlowLayout new];
    layout.maxItemSize = maxItemSize;
    layout.decreasingStep = decreasingStep;
    layout.coverOffset = coverOffset;
    return layout;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.firstLayout = YES;
    _cellCount = -1;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self setupCount];
}

- (CGSize)collectionViewContentSize {
    // 设置顶部inset，保证所有cell都能滚动到最大位置
    CGFloat topInset = self.height - self.maxCellHeight;
    self.collectionView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    
    // 获取当前cell总数
    self.cellCount = [self.collectionView numberOfItemsInSection:0];
    // 可滚动区域大小设置的大一点
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.cellContentHeight);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    CGFloat contentOffsetY = self.collectionView.contentOffset.y; // 当前滚动偏移量
    
    // 计算顶部滚出collectionView的cell数量
    NSInteger topOutSideCount = 0;
    if (contentOffsetY > 0) {
        topOutSideCount = contentOffsetY / (self.maxCellHeight - self.coverOffset);
    }
    
    // 计算底部未滚完的高度及cell数量
    NSInteger bottomOutSideCount = 0;
    CGFloat bottomOutSideHeight = self.cellContentHeight - contentOffsetY - self.height;
    if (bottomOutSideHeight > 0) {
        bottomOutSideCount = (bottomOutSideHeight - self.coverOffset) / (self.maxCellHeight - self.coverOffset);
    }
    
    // 获取最底部可见cell的序号
    NSInteger currentVisibleCount = self.cellCount - topOutSideCount - bottomOutSideCount;
    NSInteger lastVisibleIndex = topOutSideCount + currentVisibleCount - 1; // 最后一个可见cell的序号
    if (lastVisibleIndex < 0) {
        return @[];
    }
    
    // 从底部开始计算缩放，及设置坐标
    CGFloat bottomCellBottomY; // 最底部可见cell的底坐标
    CGFloat bottomCellsHeight = 0; // 在底部CollectionView外的完整cell总高度
    if (bottomOutSideCount < 1) {
        bottomCellBottomY = self.cellContentHeight;
    } else {
        bottomCellsHeight = bottomOutSideCount * (self.maxCellHeight - self.coverOffset) + self.coverOffset;
        bottomCellBottomY = self.cellContentHeight - bottomCellsHeight;
    }
    
    CGFloat layoutHeight = 0; // 完成布局计算的高度
    CGFloat rate = 0.0; // 偏移导致的缩小比例
    CGFloat bottomCellVisibleHeight = 0;
    if (bottomOutSideHeight > 0) {
        bottomCellVisibleHeight = self.maxCellHeight - (bottomOutSideHeight - bottomCellsHeight);
        layoutHeight = bottomCellVisibleHeight;
        rate = bottomCellVisibleHeight / self.maxCellHeight;
    } else {
        layoutHeight = -bottomOutSideHeight;
    }
    
    NSInteger layoutIndex = lastVisibleIndex;
    NSMutableArray *array = [NSMutableArray array];
    while (layoutHeight < self.height) {
        CGFloat cellHeight = self.maxCellHeight - self.decreasingStep * rate * (layoutIndex < lastVisibleIndex) - self.decreasingStep * (lastVisibleIndex - layoutIndex - (layoutIndex < lastVisibleIndex && bottomOutSideHeight > 0));
        CGFloat scale = cellHeight / self.maxCellHeight;
        CGFloat cellCenter = bottomCellBottomY - cellHeight / 2 + self.coverOffset*(layoutIndex<lastVisibleIndex);
        bottomCellBottomY = bottomCellBottomY - cellHeight + self.coverOffset;        
        if (layoutIndex < lastVisibleIndex) {
            layoutHeight += (cellHeight - self.coverOffset);
        }
        if (cellHeight < 0) {
            break;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:layoutIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.maxItemSize;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.frame)/2, cellCenter);
        [array insertObject:attributes atIndex:0];
        layoutIndex--;
        if (layoutIndex < 0) {
            break;
        }
    }
    return array;
}

// 保持顶部最小cell，保持minVisibleHeight
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat bottomOutSideHeight = self.cellContentHeight - proposedContentOffset.y - self.height;
    if (bottomOutSideHeight > 0) {
        NSInteger bottomOutSideCount = (bottomOutSideHeight - self.coverOffset) / (self.maxCellHeight - self.coverOffset);
        
        CGFloat bottomCellsHeight = 0;
        if (bottomOutSideCount > 0) {
            bottomCellsHeight = bottomOutSideCount * (self.maxCellHeight - self.coverOffset) + self.coverOffset;
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
    if (!self.firstLayout) {
        return;
    }
    self.maxCellHeight = self.maxItemSize.height;
    self.height = CGRectGetHeight(self.collectionView.bounds);
}

- (void)setCellCount:(NSInteger)cellCount {
    if (cellCount != _cellCount) {
        _cellCount = cellCount;
        self.cellContentHeight = self.cellCount * (self.maxCellHeight - self.coverOffset) + self.coverOffset;
        if (self.cellCount > 1) {
            self.cellContentHeight += self.coverOffset;
        }
        if (self.firstLayout) { // 第一次加载时，设置offset保证在最底部显示最后一条数据
            self.collectionView.contentOffset = CGPointMake(0, self.cellContentHeight - self.height);
            self.firstLayout = NO;
        }
    }
}

@end
