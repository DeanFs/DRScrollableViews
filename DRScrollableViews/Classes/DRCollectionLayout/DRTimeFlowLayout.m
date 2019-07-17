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
@property (nonatomic, assign) CGFloat maxDistance;          // 最大滚动距离，在此距离内随滚动缩放
@property (nonatomic, assign) CGFloat maxScale;             // 从屏幕最底部到完全滚出屏幕，cell高度减小的最大比例
@property (nonatomic, assign) CGFloat minVisibleCellHeight; // 最小可见cell的高度
@property (nonatomic, assign) CGFloat minVisibleCellVisibleHeight; // 最小可见cell留在屏幕中的高度
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数

@end

@implementation DRTimeFlowLayout

- (void)prepareLayout {
    [super prepareLayout];

    [self setupCount];
}

- (CGSize)collectionViewContentSize {
    self.cellCount = [self.collectionView numberOfItemsInSection:0];
    
    if (self.cellCount < self.visibleCount) {
        CGFloat contentHeight = self.maxItemSize.height; // 布完所有cell需要的高度
        for (NSInteger i=1; i<self.cellCount; i++) {
            contentHeight += ((self.maxItemSize.height-self.coverOffset) - i * self.decreasingStep);
        }
        self.collectionView.contentInset = UIEdgeInsetsMake(self.height-contentHeight, 0, 0, 0);
        self.collectionView.contentOffset = CGPointZero;
        return self.collectionView.frame.size;
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            CGFloat offset = self.maxItemSize.height * (self.cellCount - self.visibleCount);
            if (self.minVisibleCellHeight > self.minVisibleCellVisibleHeight) {
                offset += (self.maxItemSize.height - self.minVisibleCellVisibleHeight);
            }
            self.collectionView.contentOffset = CGPointMake(0, offset);
        });
        self.collectionView.contentInset = UIEdgeInsetsZero;
        CGFloat height = (self.cellCount - self.visibleCount) * self.maxItemSize.height + (self.maxItemSize.height + self.maxDistance);
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), height);
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger firstIndex = self.collectionView.contentOffset.y / self.maxItemSize.height;;
    NSInteger lastIndex = firstIndex + self.visibleCount - 1;
    if (self.cellCount < self.visibleCount) { // 不能铺满屏幕
        lastIndex = self.cellCount - 1;
    }
    CGFloat contentOffset = self.collectionView.contentOffset.y;
    NSInteger topCellCount = contentOffset / self.maxItemSize.height; // 完全滚出collectionView外的cell数量
    CGFloat topCellBeyondHeight = contentOffset - topCellCount * self.maxItemSize.height; // 第一个cell滚出collectionView外的高度
    CGFloat wholeScrollDistance = self.height - self.maxItemSize.height; // collectionView内最多可滚动缩放的距离
    CGFloat distance = topCellBeyondHeight + wholeScrollDistance - self.collectionView.contentInset.top;
    CGFloat y = topCellCount * self.maxItemSize.height;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = firstIndex; i <= lastIndex; i++) {
        CGFloat scale = 1 - self.maxScale * (distance / self.maxDistance);
        CGFloat cellHeight = self.maxItemSize.height * scale;
        CGFloat centerY = y + cellHeight / 2;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.maxItemSize;
        attributes.transform = CGAffineTransformMakeScale(scale, scale);
        attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.frame)/2, centerY);
        [array addObject:attributes];
        
        distance = distance - cellHeight + self.coverOffset;
        y = y + cellHeight - self.coverOffset;
    }
    return array;
}

// 保持顶部最小cell，保持minVisibleHeight
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (self.cellCount < self.visibleCount) {
        return CGPointZero;
    }
    NSInteger proposedCount = proposedContentOffset.y / self.maxItemSize.height + 1;
    return CGPointMake(0, proposedCount * self.maxItemSize.height - self.minVisibleCellVisibleHeight);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

#pragma mark - private
- (void)setupCount {
    CGFloat collectionHeight = CGRectGetHeight(self.collectionView.frame);
    CGFloat height = self.maxItemSize.height;
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
    
    self.height = collectionHeight;
    self.visibleCount = count - 1;
    self.minVisibleCellHeight = minCellHeight;
    self.minVisibleCellVisibleHeight = self.minVisibleCellHeight - (height - collectionHeight);
    
    minCellHeight = self.minVisibleCellHeight - self.decreasingStep; // cell完全滚出collectionView外后的高度
    self.maxDistance = (height + minCellHeight) - self.maxItemSize.height;
    self.maxScale = minCellHeight / self.maxItemSize.height;
}

@end
