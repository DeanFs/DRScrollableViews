//
//  UIFont+DRExtension.m
//  Records
//
//  Created by admin on 2018/11/14.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "UIFont+DRExtension.h"

@implementation UIFont (DRExtension)

+ (UIFont *)dr_PingFangSC_RegularWithSize:(CGFloat)fontSize {
    return  [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
}

+ (UIFont *)dr_PingFangSC_MediumWithSize:(CGFloat)fontSize {
    return  [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
}

+ (UIFont *)dr_PingFangSC_LightWithSize:(CGFloat)fontSize {
    return  [UIFont fontWithName:@"PingFangSC-Light" size:fontSize];
}


@end
