//
//  DRDeallocObserver.h
//  Records
//
//  Created by DuoRong on 2019/9/19.
//  Copyright © 2019 DuoRong Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRDeallocObserver : NSObject

+ (instancetype)observerWithTarget:(id)target deallocBlock:(void(^)(id target))block;

/// 绑定宿主，监听宿主销毁
/// @param parasitifer 宿主
/// @param target 需要跟随宿主销毁而做一些操作的对象，可为nil
/// @param block 宿主销毁的回调
+ (void)associateParasitifer:(id)parasitifer
                      target:(id)target
                deallocBlock:(void(^)(id target, id parasitifer))block;

@end
