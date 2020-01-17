//
//  UICollectionViewCell+TimeFlowShadowLayer.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (TimeFlowShadowLayer)

@property (nonatomic, weak) CALayer *shadowLayer;

- (void)addShadowLayerWithShadowColor:(UIColor *)color
                               offset:(CGFloat)offset
                         cornerRadius:(CGFloat)cornerRadius;

- (void)setShadowColor:(UIColor *)shadowColor;

@end

NS_ASSUME_NONNULL_END
