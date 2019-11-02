//
//  NSSet+DRExtension.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/10/29.
//

#import "NSSet+DRExtension.h"

@implementation NSSet (DRExtension)

@end


@implementation NSMutableSet (DRExtension)

- (void)safeAddObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end


@implementation NSOrderedSet (DRExtension)

@end
