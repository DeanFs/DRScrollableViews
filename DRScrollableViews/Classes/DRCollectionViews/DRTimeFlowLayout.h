//
//  DRTimeFlowLayout.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRTimeFlowLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize maxItemSize; // 最大的cell的size
@property (nonatomic, assign) CGFloat decreasingStep; // cell高度递减的值
@property (nonatomic, assign) CGFloat coverOffset; // 上一个cell被遮盖的高度值
@property (nonatomic, assign) BOOL scrollToBottomWhenFistLoad; // 第一次加载时滚动到底部，默认YES

/**
 实例化layout

 @param maxItemSize 最大的cell的size
 @param decreasingStep cell高度递减的值
 @param coverOffset 上一个cell被遮盖的高度值
 @return 实例
 */
+ (instancetype)timeFlowLayoutWithMaxtItemSize:(CGSize)maxItemSize
                                decreasingStep:(CGFloat)decreasingStep
                                   coverOffset:(CGFloat)coverOffset;

@end

NS_ASSUME_NONNULL_END
