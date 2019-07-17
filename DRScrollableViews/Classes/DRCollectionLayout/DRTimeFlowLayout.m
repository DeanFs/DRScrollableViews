//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"
#import <DRCategories/DRCategories.h>

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat height;               // collectionView Height
@property (nonatomic, assign) NSInteger visibleCount;       // 当前屏幕大小可显示的cell总数
@property (nonatomic, assign) CGFloat maxDistance;          // 最大滚动距离，在此距离内随滚动缩放
@property (nonatomic, assign) CGFloat minCellHeight;        // 可见cell中高度最小的高度
@property (nonatomic, assign) CGFloat minCellVisibleHeight; // 最小可见cell留在屏幕中的高度
@property (nonatomic, assign) NSInteger cellCount;          // 当前cell总数
@property (nonatomic, assign) BOOL firstLoad;               // 标记是否第一次加载，第一次时，最底部显示第一条数据

@end

@implementation DRTimeFlowLayout

- (void)prepareLayout {
    [super prepareLayout];

    [self setupCount];
}

- (CGSize)collectionViewContentSize {
    self.cellCount = [self.collectionView numberOfItemsInSection:0];
    
    if (self.cellCount < self.visibleCount) {
        CGFloat contentHeight = self.maxItemSize.height;
        for (NSInteger i=1; i<self.cellCount; i++) {
            contentHeight += ((self.maxItemSize.height-self.coverOffset) - i * self.decreasingStep);
        }
        self.collectionView.contentInset = UIEdgeInsetsMake(self.height-contentHeight, 0, 0, 0);
        self.collectionView.contentOffset = CGPointZero;
        return self.collectionView.frame.size;
    } else {
        if (self.firstLoad) {
            CGFloat offset = self.maxItemSize.height * (self.cellCount - self.visibleCount);
            if (self.minCellHeight > self.minCellVisibleHeight) {
                offset += (self.maxItemSize.height - self.minCellVisibleHeight);
            }
            self.collectionView.contentOffset = CGPointMake(0, offset);
            self.firstLoad = NO;
        }
        self.collectionView.contentInset = UIEdgeInsetsZero;
        CGFloat height = (self.cellCount - self.visibleCount) * self.maxItemSize.height + (self.maxItemSize.height + self.maxDistance);
        return CGSizeMake(CGRectGetWidth(self.collectionView.frame), height);
    }
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger firstIndex = self.collectionView.contentOffset.y / self.maxItemSize.height;;
    NSInteger lastIndex = firstIndex + self.visibleCount - 1;
    if (self.visibleCount > self.cellCount) { // 不能铺满屏幕
        lastIndex = self.cellCount - 1;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = firstIndex; i <= lastIndex; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [array addObject:attributes];
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.maxItemSize;
    
//    CGFloat cY = self.collectionView.contentOffset.y + self.collectionHeight / 2;
    CGFloat attributesY = self.maxItemSize.height * indexPath.row + self.maxItemSize.height / 2;
//    attributes.zIndex = -ABS(attributesY - cY);
//
//    CGFloat delta = cY - attributesY;
//    CGFloat ratio =  - delta / (self.maxItemSize.height * 2);
//    CGFloat scale = 1 - ABS(delta) / (self.maxItemSize.height * 6.0) * cos(ratio * M_PI_4);
//    attributes.transform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat centerY = attributesY;
//    switch (self.carouselAnim) {
//        case HJCarouselAnimRotary:
//            attributes.transform = CGAffineTransformRotate(attributes.transform, - ratio * M_PI_4);
//            centerY += sin(ratio * M_PI_2) * _itemHeight / 2;
//            break;
//        case HJCarouselAnimCarousel:
//            centerY = cY + sin(ratio * M_PI_2) * _itemHeight * INTERSPACEPARAM;
//            break;
//        case HJCarouselAnimCarousel1:
//            centerY = cY + sin(ratio * M_PI_2) * _itemHeight * INTERSPACEPARAM;
//            if (delta > 0 && delta <= _itemHeight / 2) {
//                attributes.transform = CGAffineTransformIdentity;
//                CGRect rect = attributes.frame;
//                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
//                    rect.origin.x = CGRectGetWidth(self.collectionView.frame) / 2 - _itemSize.width * scale / 2;
//                    rect.origin.y = centerY - _itemHeight * scale / 2;
//                    rect.size.width = _itemSize.width * scale;
//                    CGFloat param = delta / (_itemHeight / 2);
//                    rect.size.height = _itemHeight * scale * (1 - param) + sin(0.25 * M_PI_2) * _itemHeight * INTERSPACEPARAM * 2 * param;
//                } else {
//                    rect.origin.x = centerY - _itemHeight * scale / 2;
//                    rect.origin.y = CGRectGetHeight(self.collectionView.frame) / 2 - _itemSize.height * scale / 2;
//                    rect.size.height = _itemSize.height * scale;
//                    CGFloat param = delta / (_itemHeight / 2);
//                    rect.size.width = _itemHeight * scale * (1 - param) + sin(0.25 * M_PI_2) * _itemHeight * INTERSPACEPARAM * 2 * param;
//                }
//                attributes.frame = rect;
//                return attributes;
//            }
//            break;
//        case HJCarouselAnimCoverFlow: {
//            CATransform3D transform = CATransform3DIdentity;
//            transform.m34 = -1.0/400.0f;
//            transform = CATransform3DRotate(transform, ratio * M_PI_4, 1, 0, 0);
//            attributes.transform3D = transform;
//        }
//            break;
//        default:
//            break;
//    }
    
//    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        attributes.center = CGPointMake(CGRectGetWidth(self.collectionView.frame) / 2, centerY);
//    } else {
//        attributes.center = CGPointMake(centerY, CGRectGetHeight(self.collectionView.frame) / 2);
//    }
    
    return attributes;
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
    self.minCellHeight = minCellHeight;
    self.maxDistance = height - self.maxItemSize.height;
    self.minCellVisibleHeight = self.minCellHeight - (height - collectionHeight);
    self.firstLoad = YES;
}

@end
