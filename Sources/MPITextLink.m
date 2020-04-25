//
//  MPITextLink.m
//  MeituMV
//
//  Created by Tpphha on 2018/9/21.
//  Copyright © 2018年 美图网. All rights reserved.
//

#import "MPITextLink.h"
#import "MPITextEqualityHelpers.h"

@implementation MPITextLink

- (instancetype)initWithValue:(id)value {
    self = [super init];
    if (self) {
        NSParameterAssert(![value isKindOfClass:NSArray.class]);
        NSParameterAssert(![value isKindOfClass:NSDictionary.class]);
        NSParameterAssert(![value isKindOfClass:NSSet.class]);
        _value = value;
    }
    return self;
}

+ (instancetype)linkWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (NSUInteger)hash {
    return [_value hash];
}

- (BOOL)isEqual:(MPITextLink *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return MPITextObjectIsEqual(_value, object.value);
}

@end
