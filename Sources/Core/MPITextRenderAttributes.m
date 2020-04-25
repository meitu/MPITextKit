//
//  MPITextRenderAttributes.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextRenderAttributes.h"

#import "MPITextEqualityHelpers.h"
#import "MPITextHashing.h"

@implementation MPITextRenderAttributes

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineBreakMode = NSLineBreakByTruncatingTail;
        _maximumNumberOfLines = 1;
    }
    return self;
}

- (NSUInteger)hash {
    struct {
        NSUInteger attrStringHash;
        NSLineBreakMode lineBreakMode;
        NSUInteger maximumNumberOfLines;
        NSUInteger exclusionPathsHash;
        NSUInteger truncationAttrStringHash;
    } data = {
        [_attributedText hash],
        _lineBreakMode,
        _maximumNumberOfLines,
        [_exclusionPaths hash],
        [_truncationAttributedText hash]
    };
    return MPITextHashBytes(&data, sizeof(data));
}

- (BOOL)isEqual:(MPITextRenderAttributes *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return
    MPITextObjectIsEqual(_attributedText, object.attributedText) &&
    MPITextObjectIsEqual(_exclusionPaths, object.exclusionPaths) &&
    _lineBreakMode == object.lineBreakMode &&
    _maximumNumberOfLines == object.maximumNumberOfLines &&
    MPITextObjectIsEqual(_truncationAttributedText, object.truncationAttributedText);
}

@end

@implementation MPITextRenderAttributesBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineBreakMode = NSLineBreakByTruncatingTail;
        _maximumNumberOfLines = 1;
    }
    return self;
}

- (instancetype)initWithRenderAttributes:(MPITextRenderAttributes *)renderAttributes {
    self = [super init];
    if (self) {
        _attributedText = renderAttributes.attributedText;
        _exclusionPaths = renderAttributes.exclusionPaths;
        _lineBreakMode = renderAttributes.lineBreakMode;
        _maximumNumberOfLines = renderAttributes.maximumNumberOfLines;
        _truncationAttributedText = renderAttributes.truncationAttributedText;
    }
    return self;
}

- (MPITextRenderAttributes *)build {
    return [[MPITextRenderAttributes alloc] initWithBuilder:self];
}

@end

@implementation MPITextRenderAttributes (MPITextBuilderAdditions)

- (instancetype)initWithBuilder:(MPITextRenderAttributesBuilder *)builder {
    self = [super init];
    if (self) {
        _attributedText = builder.attributedText;
        _exclusionPaths = builder.exclusionPaths;
        _lineBreakMode = builder.lineBreakMode;
        _maximumNumberOfLines = builder.maximumNumberOfLines;
        _truncationAttributedText = builder.truncationAttributedText;
    }
    return self;
}

@end
