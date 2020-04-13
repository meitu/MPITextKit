//
//  MPITextEntity.m
//  MPITextKit
//
//  Created by Tpphha on 2020/4/13.
//

#import "MPITextEntity.h"
#import "MPITextEqualityHelpers.h"

@implementation MPITextEntity

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

+ (instancetype)entityWithValue:(id)value {
    return [[self alloc] initWithValue:value];
}

- (NSUInteger)hash {
    return [_value hash];
}

- (BOOL)isEqual:(MPITextEntity *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return MPITextObjectIsEqual(_value, object.value);
}

@end
