//
//  UITextField+DRExtension.m
//  Records
//
//  Created by 冯生伟 on 2018/10/31.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "UITextField+DRExtension.h"

@implementation UITextField (DRExtension)

// 设置占位字符颜色，字号
- (void)setPlaceholder:(NSString *)placeholder
                 color:(UIColor *)color
                  font:(UIFont *)font {
    NSDictionary *attrs = @{
                            NSFontAttributeName: font,
                            NSForegroundColorAttributeName: color
                            };
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:placeholder attributes:attrs];
    self.attributedPlaceholder = attStr;
}

// 去除空格的字符串
- (NSString *)validText {
    return [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
