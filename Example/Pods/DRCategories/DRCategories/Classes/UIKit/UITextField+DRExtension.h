//
//  UITextField+DRExtension.h
//  Records
//
//  Created by 冯生伟 on 2018/10/31.
//  Copyright © 2018年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (DRExtension)

// 设置占位字符颜色，字号
- (void)setPlaceholder:(NSString *)placeholder
                 color:(UIColor *)color
                  font:(UIFont *)font;

// 去除空格的字符串
- (NSString *)validText;

@end

NS_ASSUME_NONNULL_END
