//
//  MPITextLink.h
//  MeituMV
//
//  Created by Tpphha on 2018/9/21.
//  Copyright © 2018年 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
The object that should be embedded with MPITextLinkAttributeName.  Please note that the value you provide MUST
implement a proper hash and isEqual function or your application performance will grind to a halt due to
NSMutableAttributedString's usage of a global hash table of all attributes.  This means the entity should NOT be a
Foundation Collection (NSArray, NSDictionary, NSSet, etc.) since their hash function is a simple count of the values
in the collection, which causes pathological performance problems deep inside NSAttributedString's implementation.

rdar://19352367
*/
@interface MPITextLink : NSObject

@property (nullable, nonatomic, strong) id<NSObject> value;

- (instancetype)initWithValue:(id<NSObject>)value;

+ (instancetype)linkWithValue:(id<NSObject>)value;

@end

NS_ASSUME_NONNULL_END
