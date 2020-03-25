//
//  MPIExampleAttachment.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/4/19.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPIExampleAttachment.h"

@interface MPIExampleAttachment ()

@property (nonatomic, assign) BOOL highlighted;

@end

@implementation MPIExampleAttachment

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.content = image;
    }
    return self;
}

- (void)drawAttachmentInTextContainer:(NSTextContainer *)textContainer
                             textView:(UIView *)textView
                         proposedRect:(CGRect)proposedRect
                       characterIndex:(NSUInteger)characterIndex {
    NSNumber *highlightedNumber = [textContainer.layoutManager.textStorage attribute:MPITextHighlightedAttributeName
                                                                             atIndex:characterIndex
                                                                      effectiveRange:NULL];
    self.highlighted = highlightedNumber.boolValue;
    
    [super drawAttachmentInTextContainer:textContainer
                                textView:textView
                            proposedRect:proposedRect
                          characterIndex:characterIndex];
}

- (void)drawAttachmentInRect:(CGRect)rect textView:(UIView *)textView {
    if (self.highlighted) {
        [self.content drawInRect:rect blendMode:kCGBlendModeMultiply alpha:0.5];
    } else {
        [self.content drawInRect:rect];
    }
}

@end
