//
//  MPIExampleBackground.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/4/19.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPIExampleBackground.h"

@implementation MPIExampleBackground

- (CGRect)backgroundRectForTextContainer:(NSTextContainer *)textContainer
                            proposedRect:(CGRect)proposedRect
                          characterRange:(NSRange)characterRange {
    proposedRect = [super backgroundRectForTextContainer:textContainer
                                            proposedRect:proposedRect
                                          characterRange:characterRange];
    if (self.height > 0) {
        proposedRect.size.height = self.height;
    }
    return proposedRect;
}

- (NSUInteger)hash {
    struct {
        NSUInteger superHash;
        CGFloat height;
    } data = {
        [super hash],
        self.height
    };
    return MPITextHashBytes(&data, sizeof(data));
}

- (BOOL)isEqual:(MPIExampleBackground *)object {
    BOOL isEqual = [super isEqual:object];
    if (!isEqual) {
        return NO;
    }
    
    return ABS(self.height - object.height) < FLT_EPSILON;
}

@end
