//
//  NSMutableAttributedString+MPITextKit.m
//  MeituMV
//
//  Created by Tpphha on 2019/1/21.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "NSMutableAttributedString+MPITextKit.h"
#import "NSMutableParagraphStyle+MPITextKit.h"

@implementation NSMutableAttributedString (MPITextKit)

- (void)mpi_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

- (void)mpi_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self mpi_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}


#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
                 inRange:range \
                 options:kNilOptions \
              usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
                NSMutableParagraphStyle *style = nil; \
                    if (value) { \
                        if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
                            value = [NSMutableParagraphStyle mpi_styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                        } \
                        if (value. _attr_ == _attr_) return; \
                        if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
                            style = (id)value; \
                        } else { \
                            style = value.mutableCopy; \
                        } \
                    } else { \
                        if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
                        style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
                    } \
                    style. _attr_ = _attr_; \
                    [self mpi_setParagraphStyle:style range:subRange]; \
                }];

- (void)mpi_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ParagraphStyleSet(alignment);
}

- (void)mpi_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ParagraphStyleSet(baseWritingDirection);
}

- (void)mpi_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ParagraphStyleSet(lineSpacing);
}

- (void)mpi_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacing);
}

- (void)mpi_setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)mpi_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)mpi_setHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ParagraphStyleSet(headIndent);
}

- (void)mpi_setTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ParagraphStyleSet(tailIndent);
}

- (void)mpi_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ParagraphStyleSet(lineBreakMode);
}

- (void)mpi_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ParagraphStyleSet(minimumLineHeight);
}

- (void)mpi_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ParagraphStyleSet(maximumLineHeight);
}

- (void)mpi_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)mpi_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ParagraphStyleSet(hyphenationFactor);
}

- (void)mpi_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    ParagraphStyleSet(defaultTabInterval);
}

- (void)mpi_setTabStops:(NSArray *)tabStops range:(NSRange)range {
    ParagraphStyleSet(tabStops);
}

@end
