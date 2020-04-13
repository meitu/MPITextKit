//
//  MPITextEntity.h
//  MPITextKit
//
//  Created by Tpphha on 2020/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
The object that should be embedded with MPITextEntityAttributeName.  Please note that the value you provide MUST
implement a proper hash and isEqual function or your application performance will grind to a halt due to
NSMutableAttributedString's usage of a global hash table of all attributes.  This means the entity should NOT be a
Foundation Collection (NSArray, NSDictionary, NSSet, etc.) since their hash function is a simple count of the values
in the collection, which causes pathological performance problems deep inside NSAttributedString's implementation.

rdar://19352367
*/
@interface MPITextEntity : NSObject

@property (nullable, nonatomic, strong) id<NSObject> value;

- (instancetype)initWithValue:(id<NSObject>)value;

+ (instancetype)entityWithValue:(id<NSObject>)value;

@end

NS_ASSUME_NONNULL_END
