//
//  UICollectionViewCell+TimeFlowShadowLayer.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/23.
//

#import "UICollectionViewCell+TimeFlowShadowLayer.h"
#import <objc/runtime.h>

@implementation UICollectionViewCell (TimeFlowShadowLayer)

- (CALayer *)shadowLayer {
    CALayer *layer = objc_getAssociatedObject(self, @selector(addShadowLayerWithShadowColor:offset:cornerRadius:));
    return layer;
}

- (void)setShadowLayer:(CALayer *)shadowLayer {
    objc_setAssociatedObject(self, @selector(addShadowLayerWithShadowColor:offset:cornerRadius:), shadowLayer, OBJC_ASSOCIATION_ASSIGN);
}

- (void)addShadowLayerWithShadowColor:(UIColor *)color
                               offset:(CGFloat)offset
                         cornerRadius:(CGFloat)cornerRadius {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.frame = CGRectMake(0, height-offset, width, offset);
    layer.cornerRadius = cornerRadius;
    layer.colors = @[(__bridge id)[UIColor colorWithWhite:1.0 alpha:0].CGColor, (__bridge id)color.CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1.0);
    
    [self.layer addSublayer:layer];
    self.shadowLayer = layer;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    CAGradientLayer *layer = (CAGradientLayer *)self.shadowLayer;
    layer.colors = @[(__bridge id)[UIColor colorWithWhite:1.0 alpha:0].CGColor, (__bridge id)shadowColor.CGColor];
}

@end
