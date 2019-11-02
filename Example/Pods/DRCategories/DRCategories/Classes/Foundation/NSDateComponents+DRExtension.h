//
//  NSDateComponents+DRExtension.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDateComponents (DRExtension)

+ (instancetype)componentsFromTimeInterval:(int64_t)timeInterval;

+ (instancetype)componentsWithYear:(NSInteger)year
                             month:(NSInteger)month
                               day:(NSInteger)day;

+ (instancetype)componentsWithYear:(NSInteger)year
                             month:(NSInteger)month
                               day:(NSInteger)day
                              hour:(NSInteger)hour
                            minute:(NSInteger)minte
                            second:(NSInteger)second;

+ (instancetype)lunarComponentsWithEra:(NSInteger)era
                                  year:(NSInteger)year
                                 month:(NSInteger)month
                                   day:(NSInteger)day
                             leapMonth:(BOOL)leapMonth;

@end

NS_ASSUME_NONNULL_END
