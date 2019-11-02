//
//  NSSet+DRExtension.h
//  DRCategories
//
//  Created by 冯生伟 on 2019/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet<ObjectType>(DRExtension)

typedef void (^FBLFunctionalSetEnumeratorBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalSetMapperBlock)(ObjectType value);
typedef BOOL (^FBLFunctionalSetPredicateBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalSetReducerBlock)(id __nullable accumulator, ObjectType value);

/**
 Returns a set containing receiver's elements that satisfy the given predicate.
 */
- (instancetype)fbl_filter:(NS_NOESCAPE FBLFunctionalSetPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns the first element of the receiver that satisfies the given predicate.
 */
- (nullable ObjectType)fbl_first:(NS_NOESCAPE FBLFunctionalSetPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil is ignored. Mapped NSSet is flattened: its elements are appended to the results.
 */
- (NSArray *)fbl_flatMap:(NS_NOESCAPE FBLFunctionalSetMapperBlock)mapper NS_SWIFT_UNAVAILABLE("");

/**
 Calls the given block on each element of the receiver in the same order as a for-in loop.
 */
- (void)fbl_forEach:(NS_NOESCAPE FBLFunctionalSetEnumeratorBlock)block NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil appears as NSNull in resulting array.
 */
- (NSArray *)fbl_map:(NS_NOESCAPE FBLFunctionalSetMapperBlock)mapper NS_SWIFT_UNAVAILABLE("");

/**
 Returns the result of combining receiver's elements using the given reducer.
 */
- (nullable id)fbl_reduce:(nullable id)initial
                  combine:(NS_NOESCAPE FBLFunctionalSetReducerBlock)reducer
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array of pairs built out of the receiver's and provided elements. If the two containers
 have different counts, the resulting array is the same count as the shorter container.
 */
- (NSArray<NSArray *> *)fbl_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end

@interface NSMutableSet (DRExtension)

- (void)safeAddObject:(id)object;

@end


@interface NSOrderedSet<ObjectType>(DRExtension)

typedef void (^FBLFunctionalOrderedSetEnumeratorBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalOrderedSetMapperBlock)(ObjectType value);
typedef BOOL (^FBLFunctionalOrderedSetPredicateBlock)(ObjectType value);
typedef id __nullable (^FBLFunctionalOrderedSetReducerBlock)(id __nullable accumulator,
                                                             ObjectType value);

/**
 Returns an ordered set containing receiver's elements that satisfy the given predicate.
 */
- (instancetype)fbl_filter:(NS_NOESCAPE FBLFunctionalOrderedSetPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns the first element of the receiver that satisfies the given predicate.
 */
- (nullable ObjectType)fbl_first:(NS_NOESCAPE FBLFunctionalOrderedSetPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil is ignored. Mapped NSOrderedSet is flattened: its elements are appended to the results.
 */
- (NSArray *)fbl_flatMap:(NS_NOESCAPE FBLFunctionalOrderedSetMapperBlock)mapper
NS_SWIFT_UNAVAILABLE("");

/**
 Calls the given block on each element of the receiver in the same order as a for-in loop.
 */
- (void)fbl_forEach:(NS_NOESCAPE FBLFunctionalOrderedSetEnumeratorBlock)block
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil appears as NSNull in resulting array.
 */
- (NSArray *)fbl_map:(NS_NOESCAPE FBLFunctionalOrderedSetMapperBlock)mapper
NS_SWIFT_UNAVAILABLE("");

/**
 Returns the result of combining receiver's elements using the given reducer.
 */
- (nullable id)fbl_reduce:(nullable id)initial
                  combine:(NS_NOESCAPE FBLFunctionalOrderedSetReducerBlock)reducer
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array of pairs built out of the receiver's and provided elements. If the two containers
 have different counts, the resulting array is the same count as the shorter container.
 */
- (NSArray<NSArray *> *)fbl_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
