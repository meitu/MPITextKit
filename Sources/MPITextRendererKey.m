//
//  MPITextRendererKey.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextRendererKey.h"
#import "MPITextRenderAttributes.h"
#import "MPITextHashing.h"
#import "MPITextEqualityHelpers.h"

@implementation MPITextRendererKey

- (instancetype)initWithAttributes:(MPITextRenderAttributes *)attributes constrainedSize:(CGSize)constrainedSize {
    self = [super init];
    if (self) {
        _attributes = attributes;
        _constrainedSize = constrainedSize;
    }
    return self;
}

- (NSUInteger)hash {
    struct {
        size_t attributesHash;
        CGSize constrainedSize;
    } data = {
        _attributes.hash,
        _constrainedSize
    };
    return MPITextHashBytes(&data, sizeof(data));
}

- (BOOL)isEqual:(MPITextRendererKey *)object {
    if (self == object) {
        return YES;
    }
    
    if (!object) {
      return NO;
    }
    // NOTE: Skip the class check for this specialized, internal Key object.
    
    return
    MPITextObjectIsEqual(_attributes, object->_attributes)  &&
    CGSizeEqualToSize(_constrainedSize, object->_constrainedSize);
}



@end
