//
//  DRTimeFlowLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import "DRTimeFlowLayout.h"
#import <DRCategories/DRCategories.h>

@interface DRTimeFlowLayout ()

@property (nonatomic, assign) CGFloat collectionHeight;
@property (nonatomic, assign) NSInteger visibleCount;

@end

@implementation DRTimeFlowLayout

- (void)prepareLayout {
    [super prepareLayout];

    // TODO: 设置顶部偏移 contentInset
    self.collectionHeight = CGRectGetHeight(self.collectionView.frame);
    self.visibleCount = [self countVisibleCount];
}

- (CGSize)collectionViewContentSize {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), cellCount * self.maxItemSize.height);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat contentOffset = self.collectionView.contentOffset.y;
    NSInteger firstIndex = 0;
    NSInteger lastIndex = 0;
    if (contentOffset > 0) {
        firstIndex = self.collectionView.contentOffset.y / self.maxItemSize.height;
    }
    if (self.visibleCount > cellCount) { // 不能铺满屏幕
        lastIndex = cellCount - 1;
    } else {
        lastIndex = firstIndex + self.visibleCount - 1;
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

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSArray<NSIndexPath *> *visiblePaths = [self.collectionView indexPathsForVisibleItems];
    visiblePaths = [visiblePaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
        return obj1.row > obj2.row;
    }];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:visiblePaths.lastObject];
    CGFloat contentOffset = proposedContentOffset.y;
    CGFloat cellCenter = cell.y + cell.height / 2;
    CGFloat cellBottom = cell.y + cell.height;
    CGFloat contentBottom = contentOffset + self.collectionHeight;
    if (cellCenter < contentBottom) {
        return CGPointMake(0, contentOffset + cellBottom - contentBottom);
    } else if (cellCenter > contentBottom)  {
        return CGPointMake(0, contentOffset - (contentBottom - cell.y));
    }
    return proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

#pragma mark - private
- (NSInteger)countVisibleCount {
    CGFloat height = self.maxItemSize.height;
    CGFloat baseHeight = height - self.coverOffset;
    NSInteger count = 1;
    for (; height < self.collectionHeight; count++) {
        CGFloat cellHeight = baseHeight - count * self.decreasingStep;
        if (cellHeight < 0) {
            count --;
            break;
        }
        height += cellHeight;
    }
    return count;
}

@end
