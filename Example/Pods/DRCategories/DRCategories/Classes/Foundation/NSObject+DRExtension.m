//
//  NSObject+DRExtension.m
//  Records
//
//  Created by admin on 2017/12/7.
//  Copyright © 2017年 DuoRong Technology Co., Ltd. All rights reserved.
//

#import "NSObject+DRExtension.h"
#import "NSArray+DRExtension.h"
#import "NSSet+DRExtension.h"

NSArray<NSArray *> *FBLZip(id container1, id container2) {
    NSMutableArray<NSArray *> *result = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator1 = [container1 objectEnumerator];
    NSEnumerator *enumerator2 = [container2 objectEnumerator];
    for (;;) {
        id object1 = [enumerator1 nextObject];
        id object2 = [enumerator2 nextObject];
        if (!object1 || !object2) break;
        [result addObject:@[ object1, object2 ]];
    }
    return result;
}

static NSArray *FBLArrayFromContainer(id container) {
    NSArray *result = @[];
    if ([container isKindOfClass:[NSArray class]]) {
        result = container;
    } else if ([container isKindOfClass:[NSSet class]]) {
        result = [container allObjects];
    } else if ([container isKindOfClass:[NSOrderedSet class]]) {
        result = [container array];
    }
    return result;
}

/**
 Compares object classes similarly to isKindOfClass, which doesn't work for class clusters:
 NSArray<NSNumber *> isn't kind of class NSArray<NSString *> when two instances are compared.
 This method compares each instance to generic container class instead.
 */
static BOOL FBLSameKindContainers(id container1, id container2) {
    // Both containers are NSArrays.
    if ([container1 isKindOfClass:[NSArray class]] && [container2 isKindOfClass:[NSArray class]]) {
        return YES;
    }
    // Both containers are NSOrderedSets.
    if ([container1 isKindOfClass:[NSOrderedSet class]] &&
        [container2 isKindOfClass:[NSOrderedSet class]]) {
        return YES;
    }
    // Both containers are NSSets.
    if ([container1 isKindOfClass:[NSSet class]] && [container2 isKindOfClass:[NSSet class]]) {
        return YES;
    }
    return NO;
}

static id FBLFilter(id<NSFastEnumeration, NSObject> container, BOOL (^predicate)(id)) {
    id result = [[[container class] new] mutableCopy];
    for (id object in container) {
        if (predicate(object)) {
            [result addObject:object];
        }
    }
    return result;
}

static id __nullable FBLFirst(id<NSFastEnumeration> container, BOOL (^predicate)(id)) {
    for (id object in container) {
        if (predicate(object)) {
            return object;
        }
    }
    return nil;
}

static NSArray *FBLFlatMap(id<NSFastEnumeration, NSObject> container, id __nullable (^mapper)(id)) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id object in container) {
        id mapped = mapper(object);
        if (FBLSameKindContainers(container, mapped)) {
            [result addObjectsFromArray:FBLArrayFromContainer(mapped)];
        } else if (mapped) {
            [result addObject:mapped];
        }
    }
    return result;
}

static void FBLForEach(id<NSFastEnumeration> container, void (^block)(id)) {
    for (id object in container) {
        block(object);
    }
}

static NSArray *FBLMap(id<NSFastEnumeration> container, id __nullable (^mapper)(id)) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id object in container) {
        id mapped = mapper(object);
        [result addObject:mapped ?: [NSNull null]];
    }
    return result;
}

static id __nullable FBLReduce(id<NSFastEnumeration> container, id __nullable initialValue,
                               id __nullable (^reducer)(id __nullable, id)) {
    id result = initialValue;
    for (id object in container) {
        result = reducer(result, object);
    }
    return result;
}

@implementation NSObject (DRExtension)
//返回当前类的所有属性
+ (instancetype)getProperties:(Class)cls {    
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    // 遍历
    NSMutableArray *mArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        
        // An opaque type that represents an Objective-C declared property.
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [mArray addObject:name];
    }
    
    return mArray.copy;
}

+ (BOOL)compareObjectValue:(NSObject *)object WithObject:(NSObject *)object1 {
    if (![NSStringFromClass([object class])isEqualToString:NSStringFromClass([object1 class])]) {
        return NO;
    }
    NSArray *properties=(NSArray *)[NSObject getProperties:object_getClass(object)];
    for (NSString *key in properties) {
        NSString *firstString= [NSString stringWithFormat:@"%@",[object valueForKeyPath:key]];
        NSString *lastSting= [NSString stringWithFormat:@"%@",[object1 valueForKeyPath:key]];
        if(![firstString isEqualToString:lastSting]){
            return NO;
        }
    }
    return YES;
}

+ (BOOL)compareSystemEventObjectValue:(NSObject *)object WithObject:(NSObject *)object1 {
    if (![[object class] isSubclassOfClass:[object1 class]]) {
        return NO;
    }
    NSArray *properties=(NSArray *)[NSObject getProperties:object_getClass(object)];
    for (NSString *key in properties) {
        if ([key isEqualToString:@"isimportant"] || [key isEqualToString:@"colorid"]) {
            continue;
        }
        if ([object valueForKeyPath:key]||[object1 valueForKeyPath:key]) {
            if ([[[object valueForKeyPath:key] className] isEqualToString:@"__NSCFString"]&&[[[object1 valueForKeyPath:key] className] isEqualToString:@"__NSCFString"]) {//字符串判断
                if (![[object valueForKeyPath:key]isEqualToString:[object1 valueForKeyPath:key]]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

+ (void)swizzleOriginSelector:(SEL)originalSelector targetSel:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleClassOriginSelector:(SEL)originalSelector targetSel:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (instancetype)fbl_filter:(BOOL (^)(id))predicate {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(predicate);

    return FBLFilter((id<NSFastEnumeration, NSObject>)self, predicate);
}

- (nullable id)fbl_first:(BOOL (^)(id))predicate {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(predicate);

    return FBLFirst((id<NSFastEnumeration>)self, predicate);
}

- (NSArray *)fbl_flatMap:(id (^)(id))mapper {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(mapper);

    return FBLFlatMap((id<NSFastEnumeration, NSObject>)self, mapper);
}

- (void)fbl_forEach:(void (^)(id))block {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(block);

    FBLForEach((id<NSFastEnumeration>)self, block);
}

- (NSArray *)fbl_map:(id (^)(id))mapper {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(mapper);

    return FBLMap((id<NSFastEnumeration>)self, mapper);
}

- (nullable id)fbl_reduce:(nullable id)initialValue combine:(id (^)(id, id))reducer {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(reducer);

    return FBLReduce((id<NSFastEnumeration>)self, initialValue, reducer);
}

- (NSArray<NSArray *> *)fbl_zip:(id)container {
    NSParameterAssert([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert([container isKindOfClass:[NSArray class]] ||
                      [container isKindOfClass:[NSSet class]] ||
                      [container isKindOfClass:[NSOrderedSet class]]);

    return FBLZip(self, container);
}

@end
