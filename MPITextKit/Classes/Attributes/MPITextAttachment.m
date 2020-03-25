//
//  MPITextAttachmet.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAttachment.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextHashing.h"

@implementation MPITextAttachment

- (instancetype)init
{
    self = [super init];
    if (self) {
        // If you use Xcode 11 to generate applications on iOS 13 systems, attachment will render redundant decorative patterns.
        // We use the following code to avoid this behavior.
        if (@available(iOS 13, *)) {
            self.image = [UIImage new];
        }
        _verticalAligment = MPITextVerticalAlignmentCenter;
    }
    return self;
}

- (void)setContent:(id)content {
    if (_content == content) {
        return;
    }
    
    _content = content;
    
    CGSize contentSize = self.contentSize;
    if (CGSizeEqualToSize(CGSizeZero, contentSize)) {
        if ([content isKindOfClass:UIImage.class]) {
            UIImage *image = content;
            contentSize = [image size];
        } else {
            contentSize = [content bounds].size;
        }
        self.contentSize = contentSize;
    }
}

- (CGSize)attachmentSize {
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        size = self.contentSize;
    }
    return size;
}

#pragma mark - MPITextAttachmentContainer

// Returns the layout bounds to the layout manager.  The bounds origin is interpreted to match position inside lineFrag.  The NSTextAttachment implementation returns -bounds if not CGRectZero; otherwise, it derives the bounds value from -[image size].  Conforming objects can implement more sophisticated logic for negotiating the frame size based on the available container space and proposed line fragment rect.
- (CGRect)attachmentBoundsForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    UIFont *font = [textContainer.layoutManager.textStorage attribute:NSFontAttributeName atIndex:charIndex effectiveRange:nil];
    CGSize attachmentSize = self.attachmentSize;
    
    CGFloat y = font.descender; // align to text bottom.
    switch (self.verticalAligment) {
        case MPITextVerticalAlignmentTop: {
            y -= attachmentSize.height - font.lineHeight;
        } break;
        case MPITextVerticalAlignmentCenter: {
            y -= (attachmentSize.height - font.lineHeight) * 0.5;
        } break;
        case MPITextVerticalAlignmentBottom: {
        } break;
    }
    
    // The origin is relative to text baseline and based on core text coordinate system, negative means downward offset and positive upward offset.
    return (CGRect){ .origin = CGPointMake(0, y), .size = attachmentSize };
}

- (void)drawAttachmentInTextContainer:(NSTextContainer *)textContainer
                             textView:(UIView *)textView
                         proposedRect:(CGRect)proposedRect
                       characterIndex:(NSUInteger)characterIndex {
    CGRect rect = proposedRect;
    
    rect = CGRectOffset(rect, self.bounds.origin.x, self.bounds.origin.y);
    rect = UIEdgeInsetsInsetRect(rect, self.contentInsets);
    rect = MPITextCGRectFitWithContentMode(rect, self.contentSize, self.contentMode);
    rect = MPITextCGRectPixelRound(rect);
    
    [self drawAttachmentInRect:rect textView:textView];
}

- (void)drawAttachmentInRect:(CGRect)rect textView:(UIView *)textView {
    UIView *view = nil;
    CALayer *layer = nil;
    UIImage *image = nil;
    if ([self.content isKindOfClass:[UIView class]]) {
        view = self.content;
    } else if ([self.content isKindOfClass:[CALayer class]]) {
        layer = self.content;
    } else if ([self.content isKindOfClass:UIImage.class]) {
        image = self.content;
    }
    
    if (image) {
        [image drawInRect:rect];
    } else if (view) {
        if (!CGRectEqualToRect(view.frame, rect)) {
            view.frame = rect;
        }
        if (view.superview != textView) {
            [textView addSubview:view];
        }
    }else if (layer){
        if (!CGRectEqualToRect(layer.frame, rect)) {
            layer.frame = rect;
        }
        if (layer.superlayer != textView.layer) {
            [textView.layer addSublayer:layer];
        }
    }
}

- (NSUInteger)hash {
    struct {
        NSUInteger contentHash;
        MPITextVerticalAlignment verticalAligment;
        UIViewContentMode contentMode;
        CGSize contentSize;
        CGRect bounds;
        UIEdgeInsets contentInsets;
    } data = {
        [_content hash],
        _verticalAligment,
        _contentMode,
        _contentSize,
        self.bounds,
        _contentInsets,
    };
    return MPITextHashBytes(&data, sizeof(data));
}

- (BOOL)isEqual:(MPITextAttachment *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return
    MPITextObjectIsEqual(_content, object.content) &&
    _verticalAligment == object.verticalAligment &&
    _contentMode == object.contentMode &&
    CGSizeEqualToSize(_contentSize, object.contentSize) &&
    CGRectEqualToRect(self.bounds, object.bounds) &&
    UIEdgeInsetsEqualToEdgeInsets(_contentInsets, object.contentInsets);
}

@end
