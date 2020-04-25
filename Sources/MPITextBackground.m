//
//  MPITextBorder.m
//  MeituMV
//
//  Created by Tpphha on 2018/8/14.
//  Copyright © 2018年 美图网. All rights reserved.
//

#import "MPITextBackground.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextHashing.h"

@implementation MPITextBackground

- (instancetype)init {
    self = [super init];
    if (self) {
        _borderEdges = UIRectEdgeAll;
        _lineJoin = kCGLineJoinRound;
        _lineCap = kCGLineCapRound;
    }
    return self;
}

+ (instancetype)backgroundWithFillColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    MPITextBackground *one = [self new];
    one.fillColor = color;
    one.cornerRadius = cornerRadius;
    return one;
}

- (CGRect)backgroundRectForTextContainer:(NSTextContainer *)textContainer
                            proposedRect:(CGRect)proposedRect
                          characterRange:(NSRange)characterRange {
    return UIEdgeInsetsInsetRect(proposedRect, self.insets);
}

- (NSUInteger)hash {
    struct {
        CGFloat borderWidth;
        NSUInteger borderColorHash;
        NSUInteger borderEdges;
        NSUInteger lineJoin;
        NSUInteger lineCap;
        CGFloat cornerRadius;
        NSUInteger fillColorHash;
        UIEdgeInsets insets;
    } data = {
        _borderWidth,
        [_borderColor hash],
        _borderEdges,
        _lineJoin,
        _lineCap,
        _cornerRadius,
        [_fillColor hash],
        _insets,
    };
    return MPITextHashBytes(&data, sizeof(data));
}

- (BOOL)isEqual:(MPITextBackground *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return
    ABS(_borderWidth - object.borderWidth) < FLT_EPSILON &&
    MPITextObjectIsEqual(_borderColor, object.borderColor) &&
    _borderEdges == object.borderEdges &&
    _lineJoin == object.lineJoin &&
    _lineCap == object.lineCap &&
    ABS(_cornerRadius - object.cornerRadius) < FLT_EPSILON &&
    MPITextObjectIsEqual(_fillColor, object.fillColor) &&
    UIEdgeInsetsEqualToEdgeInsets(_insets, object.insets);
}

@end
