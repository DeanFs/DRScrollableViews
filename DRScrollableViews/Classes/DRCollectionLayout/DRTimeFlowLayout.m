//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat height;               // collectionView Height
@property (nonatomic, assign) NSInteger visibleCount;       // 当前屏幕大小可显示的cell总数
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数
@property (nonatomic, assign) NSInteger cellContentHeight;  // 所有cell都显示最大时的高度
@property (nonatomic, assign) CGFloat maxCellHeight;        // cell最大高度
@property (nonatomic, assign) CGFloat defaultOffset;        // cellCount < visibleCount 时的默认偏移
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
    self.scrollToBottomWhenFistLoad = YES;
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
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), self.cellContentHeight + topInset);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    CGFloat contentOffsetY = self.collectionView.contentOffset.y; // 当前滚动偏移量
    CGFloat contentSizeHeight = self.cellContentHeight;
    if (self.cellCount < self.visibleCount) {
        contentSizeHeight = self.defaultOffset + self.height;
    }
    CGFloat bottomOutSideHeight = contentSizeHeight - contentOffsetY - self.height; // 底部偏移量
    NSInteger bottomOutSideCount = bottomOutSideHeight / self.maxCellHeight; // 底部滚出CollectionView的cell数量
    NSInteger topOutSideCount = 0; // 顶部滚出CollectionView的cell数量
    if (contentOffsetY > 0) {
        topOutSideCount = contentOffsetY / self.maxCellHeight;
    }
    
    NSInteger firstVisibleIndex = topOutSideCount; // 第一个可见cell的序号
    NSInteger currentVisibleCount = self.cellCount - topOutSideCount - bottomOutSideCount;
    NSInteger lastVisibleIndex = firstVisibleIndex + currentVisibleCount - 1; // 最后一个可见cell的序号
    
    // 从底部开始计算缩放，及设置坐标
    CGFloat bottomCellOutHeight = bottomOutSideHeight - bottomOutSideCount * self.maxCellHeight; // 最底部cell不可见高度
    CGFloat bottomCellVisibleHeight = self.maxCellHeight - bottomCellOutHeight; // 最底部cell可见高度
    CGFloat bottomCellBottomY = self.cellContentHeight - bottomOutSideHeight + bottomCellOutHeight;
    CGFloat rate = bottomCellVisibleHeight / self.maxCellHeight; // 偏移导致的缩小比例
    CGFloat layoutHeight = bottomCellVisibleHeight; // 完成布局计算的高度
    NSInteger layoutIndex = lastVisibleIndex;
    NSMutableArray *array = [NSMutableArray array];
    while (layoutHeight < self.height) {
        CGFloat cellHeight = self.maxCellHeight - self.decreasingStep * rate * (layoutIndex < lastVisibleIndex) - self.decreasingStep * (lastVisibleIndex - layoutIndex - (layoutIndex < lastVisibleIndex));
        if (layoutIndex+1 == lastVisibleIndex && bottomCellVisibleHeight <= self.coverOffset) {
            bottomCellBottomY -= self.coverOffset;
            cellHeight = self.maxCellHeight;
        }
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
    return proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

#pragma mark - private
- (void)setupCount {
    CGFloat maxCellHeight = self.maxItemSize.height;
    CGFloat collectionHeight = CGRectGetHeight(self.collectionView.frame);
    CGFloat height = maxCellHeight;
    CGFloat baseHeight = height - self.coverOffset;
    CGFloat minCellHeight = height;
    NSInteger count = 1;
    while (height < collectionHeight) {
        CGFloat cellHeight = baseHeight - count * self.decreasingStep;
        if (cellHeight < 0) {
            break;
        }
        minCellHeight = cellHeight;
        height += cellHeight;
        count ++;
    }
    
    self.maxCellHeight = maxCellHeight;
    self.height = collectionHeight;
    self.visibleCount = count - 1;
}

- (void)setCellCount:(NSInteger)cellCount {
    if (cellCount != _cellCount) {
        _cellCount = cellCount;
        self.cellContentHeight = self.cellCount * self.maxCellHeight;
        if (self.cellCount < self.visibleCount) {
            CGFloat needHeight = self.maxCellHeight; // 布完所有cell需要的高度
            for (NSInteger i=1; i<self.cellCount; i++) {
                needHeight += ((self.maxCellHeight-self.coverOffset) - i * self.decreasingStep);
            }
            self.defaultOffset = needHeight - self.height;
            self.collectionView.contentOffset = CGPointMake(0, self.defaultOffset);
        } else {
            if (self.firstLayout && self.scrollToBottomWhenFistLoad) { // 第一次加载时，设置offset保证在最底部显示最后一条数据
                self.collectionView.contentOffset = CGPointMake(0, self.cellContentHeight - self.height);
                self.firstLayout = NO;
            }
        }
    }
}

@end
