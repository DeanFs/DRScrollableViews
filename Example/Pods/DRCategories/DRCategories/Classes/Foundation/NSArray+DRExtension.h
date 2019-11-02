//
//  NSArray+DRExtension.h
//  DRBasicKit
//
//  Created by 冯生伟 on 2019/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType>(DRExtension)

- (id)safeGetObjectWithIndex:(NSInteger)index;

typedef void (^FBLFunctionalArrayEnumeratorBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalArrayMapperBlock)(ObjectType value);
typedef BOOL (^FBLFunctionalArrayPredicateBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalArrayReducerBlock)(id __nullable accumulator,
                                                        ObjectType value);

/**
 Returns an array containing receiver's elements that satisfy the given predicate.
 */
- (instancetype)fbl_filter:(NS_NOESCAPE FBLFunctionalArrayPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns the first element of the receiver that satisfies the given predicate.
 */
- (nullable ObjectType)fbl_first:(NS_NOESCAPE FBLFunctionalArrayPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil is ignored. Mapped NSArray is flattened: its elements are appended to the results.
 */
- (NSArray *)fbl_flatMap:(NS_NOESCAPE FBLFunctionalArrayMapperBlock)mapper NS_SWIFT_UNAVAILABLE("");

/**
 Calls the given block on each element of the receiver in the same order as a for-in loop.
 */
- (void)fbl_forEach:(NS_NOESCAPE FBLFunctionalArrayEnumeratorBlock)block NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil appears as NSNull in resulting array.
 */
- (NSArray *)fbl_map:(NS_NOESCAPE FBLFunctionalArrayMapperBlock)mapper NS_SWIFT_UNAVAILABLE("");

/**
 Returns the result of combining receiver's elements using the given reducer.
 */
- (nullable id)fbl_reduce:(nullable id)initialValue
                  combine:(NS_NOESCAPE FBLFunctionalArrayReducerBlock)reducer
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array of pairs built out of the receiver's and provided elements. If the two containers
 have different counts, the resulting array is the same count as the shorter container.
 */
- (NSArray<NSArray *> *)fbl_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end


@interface NSMutableArray (DRSafeInsert)

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)safeInsertObjects:(NSArray<id> *)objects atIndexes:(NSIndexSet *)indexes;

@end

NS_ASSUME_NONNULL_END
