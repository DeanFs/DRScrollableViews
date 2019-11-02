//
//  DRSectorDeleteView.m
//  Records
//
//  Created by Jeason on 2018/6/6.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "DRSectorDeleteView.h"
#import <HexColors/HexColors.h>
#import <Masonry/Masonry.h>
#import <AudioToolbox/AudioToolbox.h>
#import <DRMacroDefines/DRMacroDefines.h>
#import <DRCategories/UIFont+DRExtension.h>

static const CGFloat DRSectorDeleteViewWidth = 140.0;

@interface DRSectorDeleteView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, weak) UILabel *deleteTextLabel;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) BOOL isZoom;

@end

@implementation DRSectorDeleteView

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat width = DRSectorDeleteViewWidth;
        CGPoint center = CGPointMake(width, width);
        
        //扇形背景
        self.backgroundView = ({
            UIView *view = [[UIView alloc] init];
            UIBezierPath *path = [[UIBezierPath alloc] init];
            [path moveToPoint:center];
            [path addArcWithCenter:center radius:width startAngle:M_PI * 0 endAngle:M_PI * 2 clockwise:YES];
            [path closePath];
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.path = path.CGPath;
            layer.strokeColor = [UIColor hx_colorWithHexRGBAString:@"FC5B5B"].CGColor;
            layer.fillColor = [UIColor hx_colorWithHexRGBAString:@"FC5B5B"].CGColor;
            layer.frame = CGRectMake(0, 0, width, width);
            [view.layer addSublayer:layer];
            view;
        });
        [self addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        //删除图标
        NSString *imageName = [NSString stringWithFormat:@"sector_delete@%dx", (int)[UIScreen mainScreen].scale];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[KDR_CURRENT_BUNDLE pathForResource:imageName ofType:@"png"]]];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-40.0);
            make.bottom.equalTo(self).offset(-50.0);
        }];
        self.imageView = imageView;
        
        //标题
        UILabel *label = [[UILabel alloc] init];
        label.text = @"拖至此处删除";
        label.font = [UIFont dr_PingFangSC_RegularWithSize:10];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imageView);
            make.top.equalTo(imageView.mas_bottom).offset(10.0);
        }];
        self.deleteTextLabel = label;
    }
    return self;
}

- (void)show {
    AudioServicesPlaySystemSound(1519);
    CGFloat width = DRSectorDeleteViewWidth;
    self.frame = CGRectMake(kDRScreenWidth, kDRScreenHeight, width, width);
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.frame = CGRectMake(kDRScreenWidth - width, kDRScreenHeight - width, width, width);
    } completion:^(BOOL finished) {
    
    }];
}

- (void)dismiss {
    [self dismissComplete:nil];
}

- (void)dismissComplete:(dispatch_block_t)complete {
    CGFloat width = DRSectorDeleteViewWidth;
    self.frame = CGRectMake(kDRScreenWidth - width, kDRScreenHeight - width, width, width);
    [UIView animateWithDuration:kDRAnimationDuration animations:^{
        self.frame = CGRectMake(kDRScreenWidth, kDRScreenHeight, width, width);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        kDR_SAFE_BLOCK(complete);
    }];
}

- (void)backgroundAnimationWithIsZoom:(BOOL)isZoom {
    if (self.isZoom != isZoom) {
        self.isZoom = isZoom;
        if (isZoom) {
            AudioServicesPlaySystemSound(1519);
        }
        CGFloat width = DRSectorDeleteViewWidth;
        [UIView animateWithDuration:kDRAnimationDuration animations:^{
            if (isZoom) {
                self.backgroundView.frame = CGRectMake(-10, -10,width,width);
            } else {
                self.backgroundView.frame = CGRectMake(0, 0, width, width);
            }
        }];
    }
}

- (void)setDeteteText:(NSString *)deleteText {
    self.deleteTextLabel.text = deleteText;
}

- (void)setDeleteTextFont:(UIFont *)textFont {
    self.deleteTextLabel.font = textFont;
}

- (void)setDeleteIconImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)dealloc {
    kDR_LOG(@"%@ dealloc", NSStringFromClass([self class]));
}

@end
