//
//  NSDateComponents+DRExtension.m
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/21.
//

#import "NSDateComponents+DRExtension.h"

@implementation NSDateComponents (DRExtension)

+ (instancetype)componentsFromTimeInterval:(int64_t)timeInterval {
    NSDateComponents *components = [NSDateComponents new];
    components.day = timeInterval / 86400;
    timeInterval %= 86400;
    
    components.hour = timeInterval / 3600;
    timeInterval %= 3600;
    
    components.minute = timeInterval / 60;
    components.second = timeInterval % 60;
    return components;
}

+ (instancetype)componentsWithYear:(NSInteger)year
                             month:(NSInteger)month
                               day:(NSInteger)day {
    NSDateComponents *cmp = [NSDateComponents new];
    cmp.year = year;
    cmp.month = month;
    cmp.day = day;
    return cmp;
}

+ (instancetype)componentsWithYear:(NSInteger)year
                             month:(NSInteger)month
                               day:(NSInteger)day
                              hour:(NSInteger)hour
                            minute:(NSInteger)minte
                            second:(NSInteger)second {
    NSDateComponents *cmp = [NSDateComponents new];
    cmp.year = year;
    cmp.month = month;
    cmp.day = day;
    cmp.hour = hour;
    cmp.minute = minte;
    cmp.second = second;
    return cmp;
}

+ (instancetype)lunarComponentsWithEra:(NSInteger)era
                                  year:(NSInteger)year
                                 month:(NSInteger)month
                                   day:(NSInteger)day
                             leapMonth:(BOOL)leapMonth {
    NSDateComponents *cmp = [NSDateComponents new];
    cmp.era = era;
    cmp.year = year;
    cmp.month = month;
    cmp.day = day;
    cmp.leapMonth = leapMonth;
    return cmp;
}

@end
