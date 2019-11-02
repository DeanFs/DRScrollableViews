//
//  NSDictionary+DRExtension.h
//  DRBasicKit
//
//  Created by 冯生伟 on 2019/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType>(DRExtension)

typedef void (^FBLFunctionalDictionaryEnumeratorBlock)(KeyType key, ObjectType value);
typedef id __nullable (^FBLFunctionalDictionaryMapperBlock)(KeyType key, ObjectType value);
typedef BOOL (^FBLFunctionalDictionaryPredicateBlock)(KeyType key, ObjectType value);
typedef id __nullable (^FBLFunctionalDictionaryReducerBlock)(id __nullable accumulator, KeyType key,
                                                             ObjectType value);
typedef id __nullable (^FBLFunctionalDictionaryValueMapperBlock)(ObjectType value);

/**
 Returns a dictionary containing receiver's elements that satisfy the given predicate.
 */
- (instancetype)fbl_filter:(NS_NOESCAPE FBLFunctionalDictionaryPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns the key of the first element of the receiver that satisfies the given predicate.
 */
- (nullable KeyType)fbl_first:(NS_NOESCAPE FBLFunctionalDictionaryPredicateBlock)predicate
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil is ignored. Mapped NSDictionary is flattened: its values are appended to the results.
 */
- (NSArray *)fbl_flatMap:(NS_NOESCAPE FBLFunctionalDictionaryMapperBlock)mapper
NS_SWIFT_UNAVAILABLE("");

/**
 Calls the given block on each element of the receiver in the same order as a for-in loop.
 */
- (void)fbl_forEach:(NS_NOESCAPE FBLFunctionalDictionaryEnumeratorBlock)block
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array containing the results of mapping the given mapper over receiver’s elements.
 Mapped nil appears as NSNull in resulting array.
 */
- (NSArray *)fbl_map:(NS_NOESCAPE FBLFunctionalDictionaryMapperBlock)mapper
NS_SWIFT_UNAVAILABLE("");

/**
 Returns a dictionary containing receiver’s keys with the values transformed by the given mapper.
 Mapped nil appears as NSNull in resulting array.
 */
- (NSDictionary<KeyType, id> *)fbl_mapValues:
(NS_NOESCAPE FBLFunctionalDictionaryValueMapperBlock)mapper NS_SWIFT_UNAVAILABLE("");

/**
 Returns the result of combining receiver's elements using the given reducer.
 */
- (nullable id)fbl_reduce:(nullable id)initialValue
                  combine:(NS_NOESCAPE FBLFunctionalDictionaryReducerBlock)reducer
NS_SWIFT_UNAVAILABLE("");

/**
 Returns an array of pairs built out of the receiver's and provided elements. If the two containers
 have different counts, the resulting array is the same count as the shorter container.
 */
- (NSArray<NSArray *> *)fbl_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end


@interface NSMutableDictionary (DRSafeAccess)

- (void)safeSetObject:(id)object forKey:(id <NSCopying> )key;

@end

NS_ASSUME_NONNULL_END
