//
//  DRFoldableOptionItemLayout.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/9/4.
//

#import "DRFoldableOptionItemLayout.h"

@interface DRFoldableOptionItemLayout ()

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation DRFoldableOptionItemLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.height = CGRectGetHeight(self.collectionView.frame);
    self.width = CGRectGetWidth(self.collectionView.frame);
    self.itemSize = CGSizeMake(self.itemWidth, self.height);
}

- (CGSize)collectionViewContentSize {
    self.itemCount = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(self.itemCount * self.self.itemWidth, self.height);
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.itemCount == 0) {
        return @[];
    }
    
    // 获取左侧第一个可见cell的序号
    CGFloat contentOffsetX = self.collectionView.contentOffset.x; // 当前滚动偏移量
    NSInteger firstVisibleIndex = contentOffsetX / self.itemWidth;
    
    // 获取第一个可见cell的可见宽度
    CGFloat firstVisibleCellWidth = (firstVisibleIndex+1) * self.itemWidth - contentOffsetX;
    
    // 设置布局信息
    NSInteger layoutIndex = firstVisibleIndex;
    CGFloat layoutWidth = firstVisibleCellWidth;
    CGFloat fullWidth = self.width + self.itemWidth;
    NSMutableArray *array = [NSMutableArray array];
    while (layoutWidth <= fullWidth) {
        if (layoutIndex >= self.itemCount) { // 全部布局完
            break;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:layoutIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.itemSize;
        attributes.center = CGPointMake(self.itemWidth/2 + layoutIndex * self.itemWidth, self.itemSize.height/2);
        
        [array addObject:attributes];
        
        layoutIndex ++;
        layoutWidth += self.itemWidth;
    }
    
    // 设置左右两边残缺item的透明不
    // 左边
    UICollectionViewLayoutAttributes *firstAttributes = array.firstObject;
    CGFloat firstItemRight = firstAttributes.center.x + self.itemWidth / 2;
    CGFloat rate = (firstItemRight - contentOffsetX) / self.itemWidth;
    firstAttributes.alpha = rate * rate;
    
    // 右边，保险起见，遍历一下为好
    CGFloat maxRight = contentOffsetX + self.width;
    for (NSInteger i=array.count-1; i>0; i--) {
        UICollectionViewLayoutAttributes *attributes = array[i];
        CGFloat itemLeft = attributes.center.x - self.itemWidth / 2;
        if (itemLeft > maxRight) { // 在屏幕外
            continue;
        }
        CGFloat itemRitht = attributes.center.x + self.itemWidth / 2;
        CGFloat visibleWidth = self.itemWidth - (itemRitht - maxRight);
        CGFloat rate = visibleWidth / self.itemWidth;
        attributes.alpha = rate * rate;
        break;
    }
    
    // 设置展开/收起时的缩放
    if (self.expandHeight < self.height) {
        CGFloat gapRate = (1 - 0.1 * array.count) / 2;
        CGFloat startShowHeight = gapRate * self.height;
        CGFloat durationHeight = startShowHeight;
        CGFloat stepHeight = self.height / 10;
        for (NSInteger i=0; i<array.count; i++) {
            UICollectionViewLayoutAttributes *attributes = array[i];
            startShowHeight = durationHeight + stepHeight * i;
            CGFloat rate = 0.0;
            if (startShowHeight < self.expandHeight) {
                rate = (self.expandHeight - startShowHeight) / durationHeight;
                if (rate > 1) {
                    rate = 1;
                }
                attributes.alpha *= rate * rate;
            } else {
                attributes.alpha = 0.0;
            }
            CGFloat scale = 0.3 + 0.7 * rate;
            attributes.transform = CGAffineTransformMakeScale(scale, scale);
            
            CGPoint center = attributes.center;
            CGFloat y = self.height - self.expandHeight / 2;
            attributes.center = CGPointMake(center.x, y);
        }
    }    
    return array;
}

@end
