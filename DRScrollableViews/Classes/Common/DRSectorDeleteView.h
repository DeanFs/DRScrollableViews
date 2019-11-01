//
//  DRSectorDeleteView.h
//  Records
//
//  Created by Jeason on 2018/6/6.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRSectorDeleteView : UIView

- (void)show;
- (void)dismiss;
- (void)dismissComplete:(dispatch_block_t)complete;
- (void)backgroundAnimationWithIsZoom:(BOOL)isZoom;
- (void)setDeteteText:(NSString *)deleteText;
- (void)setDeleteTextFont:(UIFont *)textFont;
- (void)setDeleteIconImage:(UIImage *)image;

@end
