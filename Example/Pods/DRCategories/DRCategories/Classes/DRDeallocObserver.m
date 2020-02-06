//
//  DRDeallocObserver.m
//  Records
//
//  Created by DuoRong on 2019/9/19.
//  Copyright © 2019 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "DRDeallocObserver.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <objc/runtime.h>

@interface DRDeallocObserver ()  {
    __unsafe_unretained id m_target;
    __unsafe_unretained id m_parasitifer;
}

@property (nonatomic, copy) void(^deallocBlock)(id target);
@property (copy, nonatomic) void(^deallocBlock2)(id target, id parasitifer);

@end

@implementation DRDeallocObserver

+ (instancetype)observerWithTarget:(id)target deallocBlock:(void(^)(id target))block {
    DRDeallocObserver *obs = [DRDeallocObserver new];
    obs.deallocBlock = block;
    obs.target = target;
    return obs;
}

- (void)setTarget:(id)target {
    m_target = target;
}

- (void)setParasitifer:(id)parasitifer {
    m_parasitifer = parasitifer;
}

- (void)dealloc {
    kDR_SAFE_BLOCK(self.deallocBlock, m_target);
    kDR_SAFE_BLOCK(self.deallocBlock2, m_target, m_parasitifer);
    m_target = nil;
    m_parasitifer = nil;
}

/// 绑定宿主，监听宿主销毁
/// @param parasitifer 宿主
/// @param target 需要跟随宿主销毁而做一些操作的对象，可为nil
/// @param block 宿主销毁的回调
+ (void)associateParasitifer:(id)parasitifer
                      target:(id)target
                deallocBlock:(void(^)(id target, id parasitifer))block {
    DRDeallocObserver *obs = [DRDeallocObserver new];
    obs.target = target;
    obs.parasitifer = parasitifer;
    obs.deallocBlock2 = block;
    objc_setAssociatedObject(parasitifer, _cmd, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
