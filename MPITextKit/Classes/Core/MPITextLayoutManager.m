//
//  MPITextLayoutManager.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextLayoutManager.h"
#import "MPITextAttachmentsInfo.h"
#import "MPITextBackgroundsInfo.h"
#import "MPITextAttachment.h"
#import "MPITextAttributes.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextDebugOption.h"
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSInteger, MPITextBackgroundType) {
    MPITextBackgroundTypeNormal,
    MPITextBackgroundTypeBlock
};

/**
 NOTE:
 -fillBackgroundRectArray:count:forCharacterRange:color: The draws is incorrect in this method.
 -truncatedGlyphRangeInLineFragmentForGlyphAtIndex: The retuns result incorrect in multi line text line break.
 */
@interface MPITextLayoutManager ()

@end

@implementation MPITextLayoutManager

#pragma mark - Background

- (MPITextBackgroundsInfo *)backgroundsInfoWithBackgroundType:(MPITextBackgroundType)backgroundType
                                                forGlyphRange:(NSRange)glyphsToShow
                                              inTextContainer:(NSTextContainer *)textContainer {
    if (glyphsToShow.length == 0) {
        return nil;
    }
    
    NSTextStorage *textStorage = self.textStorage;
    NSRange characterRangeToShow = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:NULL];
    
    NSMutableArray<NSArray *> *backgroundRectArrays = [NSMutableArray new];
    NSMutableArray<NSValue *> *backgroundCharacterRanges = [NSMutableArray new];
    NSMutableArray<MPITextBackground *> *backgrounds = [NSMutableArray new];
    NSAttributedStringKey attributeKey = backgroundType == MPITextBackgroundTypeNormal ? MPITextBackgroundAttributeName : MPITextBlockBackgroundAttributeName;
    [textStorage enumerateAttribute:attributeKey inRange:characterRangeToShow options:kNilOptions usingBlock:^(MPITextBackground  *_Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (!value) {
            return;
        }
        
        NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:NULL];
        if (glyphRange.location == NSNotFound) {
            return;
        }
        
        NSMutableArray<NSValue *> *rects = [NSMutableArray new];
        if (backgroundType == MPITextBackgroundTypeNormal) {
            [self enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0) inTextContainer:textContainer usingBlock:^(CGRect rect, BOOL *stop) {
                CGRect proposedRect = rect;
                
                // This method may return a larger value.
                // NSRange glyphRange = [self glyphRangeForBoundingRect:proposedRect inTextContainer:textContainer];
                NSUInteger startGlyphIndex = [self glyphIndexForPoint:CGPointMake(MPITextCGFloatPixelCeil(CGRectGetMinX(proposedRect)), CGRectGetMidY(proposedRect)) inTextContainer:textContainer];
                NSUInteger endGlyphIndex = [self glyphIndexForPoint:CGPointMake(MPITextCGFloatPixelFloor(CGRectGetMaxX(proposedRect)), CGRectGetMidY(proposedRect)) inTextContainer:textContainer];
                NSRange glyphRange = NSMakeRange(startGlyphIndex, endGlyphIndex - startGlyphIndex + 1);
                NSRange characterRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
                
                proposedRect = [value  backgroundRectForTextContainer:textContainer
                                                         proposedRect:proposedRect
                                                       characterRange:characterRange];
                
                [rects addObject:[NSValue valueWithCGRect:proposedRect]];
            }];
        } else if (backgroundType == MPITextBackgroundTypeBlock){
            CGRect blockRect;
            NSRange effectiveGlyphRange;
            CGRect startLineFragmentRect = [self lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:&effectiveGlyphRange];
            NSUInteger maxGlyphIndex = NSMaxRange(glyphRange) - 1;
            if (NSLocationInRange(maxGlyphIndex, effectiveGlyphRange)) { // in the same line
                CGRect startLineUsedFragment = [self lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:NULL];
                blockRect = startLineFragmentRect;
                blockRect.size.height = CGRectGetHeight(startLineUsedFragment);
            } else {
                CGRect endLineFragmentRect = [self lineFragmentRectForGlyphAtIndex:maxGlyphIndex effectiveRange:NULL];
                CGRect endLineUsedFragmentRect = [self lineFragmentUsedRectForGlyphAtIndex:maxGlyphIndex effectiveRange:NULL];
                blockRect = endLineFragmentRect;
                blockRect.size.height = CGRectGetHeight(endLineUsedFragmentRect);
                blockRect = CGRectUnion(startLineFragmentRect, blockRect);
            }
            blockRect = [value backgroundRectForTextContainer:textContainer
                                                 proposedRect:blockRect
                                               characterRange:range];
            [rects addObject:[NSValue valueWithCGRect:blockRect]];
        }
        
        [backgroundRectArrays addObject:rects];
        [backgroundCharacterRanges addObject:[NSValue valueWithRange:range]];
        [backgrounds addObject:value];
    }];
    
    if (backgrounds.count > 0) {
        return [[MPITextBackgroundsInfo alloc] initWithBackgrounds:backgrounds
                                              backgroundRectArrays:backgroundRectArrays
                                         backgroundCharacterRanges:backgroundCharacterRanges];
    }
    return nil;
}

- (MPITextBackgroundsInfo *)backgroundsInfoForGlyphRange:(NSRange)glyphsToShow inTextContainer:(NSTextContainer *)textContainer {
    NSMutableArray<MPITextBackground *> *backgrounds = [NSMutableArray new];
    NSMutableArray<NSArray *> *backgroundRectArrays = [NSMutableArray new];
    NSMutableArray<NSValue *> *backgroundCharacterRanges = [NSMutableArray new];
    
    void(^mergeBackgroundsInfo)(MPITextBackgroundsInfo *) = ^(MPITextBackgroundsInfo *backgroundsInfo) {
        if (backgroundsInfo.backgrounds.count > 0) {
            [backgrounds addObjectsFromArray:backgroundsInfo.backgrounds];
            [backgroundRectArrays addObjectsFromArray:backgroundsInfo.backgroundRectArrays];
            [backgroundCharacterRanges addObjectsFromArray:backgroundsInfo.backgroundCharacterRanges];
        }
    };
    
    MPITextBackgroundsInfo *normalBackgroundsInfo = [self backgroundsInfoWithBackgroundType:MPITextBackgroundTypeNormal forGlyphRange:glyphsToShow inTextContainer:textContainer];
    MPITextBackgroundsInfo *blockBackgroundsInfo = [self backgroundsInfoWithBackgroundType:MPITextBackgroundTypeBlock forGlyphRange:glyphsToShow inTextContainer:textContainer];
    
    // Rendering order: block > normal
    mergeBackgroundsInfo(blockBackgroundsInfo);
    mergeBackgroundsInfo(normalBackgroundsInfo);
    
    if (backgrounds.count > 0) {
        return [[MPITextBackgroundsInfo alloc] initWithBackgrounds:backgrounds
                                              backgroundRectArrays:backgroundRectArrays
                                         backgroundCharacterRanges:backgroundCharacterRanges];
    }
    return nil;
}

- (void)fillBackground:(MPITextBackground *)background rectArray:(NSArray<NSValue *> *)rectArray atPoint:(CGPoint)origin forCharacterRange:(NSRange)charRange  {
    CGFloat cornerRadius = background.cornerRadius;
    UIColor *strokeColor = background.borderColor;
    CGFloat strokeWidth = background.borderWidth;
    UIRectEdge borderEdges = background.borderEdges;
    CGLineJoin lineJoin = background.lineJoin;
    CGLineCap lineCap = background.lineCap;
    UIColor *color = background.fillColor;
    
    if (!color && !strokeColor) {
        return;
    }
    
    // background
    NSMutableArray *paths = [NSMutableArray new];
    for (NSUInteger index = 0; index < rectArray.count; index++) {
        CGRect rect = [rectArray[index] CGRectValue];
        rect.origin.x += origin.x;
        rect.origin.y += origin.y;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        [path closePath];
        [paths addObject:path];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    for (UIBezierPath *path in paths) {
        CGContextAddPath(context, path.CGPath);
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    // stroke
    if (strokeColor && strokeWidth > 0) {
        CGFloat inset = strokeWidth * 0.5;
        NSMutableArray *paths = [NSMutableArray new];
        for (NSUInteger index = 0; index < rectArray.count; index++) {
            CGRect rect = [rectArray[index] CGRectValue];
            rect.origin.x += origin.x;
            rect.origin.y += origin.y;
            rect = CGRectInset(rect, inset, inset);
            UIBezierPath *path = nil;
            if (borderEdges == UIRectEdgeAll) {
                CGFloat scaledCornerRadius = cornerRadius;
                if (inset > 0) {
                    scaledCornerRadius = MPITextCGFloatPixelFloor(cornerRadius * (1 - inset / CGRectGetHeight(rect)));
                }
                path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:scaledCornerRadius];
                [path closePath];
            } else {
                path = [UIBezierPath bezierPath];
                CGFloat minX = CGRectGetMinX(rect);
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat minY = CGRectGetMinY(rect);
                CGFloat maxY = CGRectGetMaxY(rect);
                if (borderEdges & UIRectEdgeTop) {
                    [path moveToPoint:CGPointMake(maxX, minY)];
                    [path addLineToPoint:CGPointMake(minX, minY)];
                }
                if (borderEdges & UIRectEdgeLeft) {
                    [path moveToPoint:CGPointMake(minX, minY)];
                    [path addLineToPoint:CGPointMake(minX, maxY)];
                }
                if (borderEdges & UIRectEdgeBottom) {
                    [path moveToPoint:CGPointMake(minX, maxY)];
                    [path addLineToPoint:CGPointMake(maxX, maxY)];
                }
                if (borderEdges & UIRectEdgeRight) {
                    [path moveToPoint:CGPointMake(maxX, maxY)];
                    [path addLineToPoint:CGPointMake(maxX, minY)];
                }
            }
            [paths addObject:path];
        }
        
        CGContextSaveGState(context);
        for (UIBezierPath *path in paths) {
            CGContextAddPath(context, path.CGPath);
        }
        CGContextSetLineWidth(context, strokeWidth);
        CGContextSetLineJoin(context, lineJoin);
        CGContextSetLineCap(context, lineCap);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

- (void)drawBackgroundWithBackgroundsInfo:(MPITextBackgroundsInfo *)backgroundsInfo atPoint:(CGPoint)origin {
    if (!backgroundsInfo) {
        return;
    }
    
    NSArray<NSArray *> *backgroundRectArrays = backgroundsInfo.backgroundRectArrays;
    NSArray<NSValue *> *backgroundCharacterRanges = backgroundsInfo.backgroundCharacterRanges;
    NSArray<MPITextBackground *> *backgrounds = backgroundsInfo.backgrounds;
    if (backgroundRectArrays.count != backgroundCharacterRanges.count ||
        backgroundRectArrays.count != backgrounds.count) {
        NSAssert(NO, @"Invalid backgroundsInfo: %@.", backgroundsInfo);
        return;
    }
    
    for (NSUInteger i = 0; i < backgroundRectArrays.count; i++) {
        NSArray<NSValue *> *rectArray = backgroundRectArrays[i];
        NSRange characterRange = backgroundCharacterRanges[i].rangeValue;
        MPITextBackground *background = backgrounds[i];
        [self fillBackground:background rectArray:rectArray atPoint:origin forCharacterRange:characterRange];
    }
}

#pragma mark - Attachment

- (MPITextAttachmentsInfo *)attachmentsInfoForGlyphRange:(NSRange)glyphsToShow inTextContainer:(NSTextContainer *)textContainer {
    if (glyphsToShow.length == 0) {
        return nil;
    }
    
    NSTextStorage *textStorage = self.textStorage;
    
    NSMutableArray<MPITextAttachment *> *attachments = [NSMutableArray new];
    NSMutableArray<MPITextAttachmentInfo *> *attachmentInfos = [NSMutableArray new];
    
    NSRange characterRange = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:NULL];
    [textStorage enumerateAttribute:NSAttachmentAttributeName inRange:characterRange options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (![value isKindOfClass:MPITextAttachment.class]) {
            return;
        }
        
        MPITextAttachment *attachment = (MPITextAttachment *)value;
        
        NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:NULL];
        CGRect attachmentFrame = [self boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
        CGPoint location = [self locationForGlyphAtIndex:glyphRange.location];
        
        // location.y is attachment's frame maxY，this behaviors depends on TextKit and MPITextAttachment implementation.
        attachmentFrame.origin.y += location.y;
        attachmentFrame.origin.y -= attachment.attachmentSize.height;
        attachmentFrame.size.height = attachment.attachmentSize.height;
        
        MPITextAttachmentInfo *attachmentInfo = [[MPITextAttachmentInfo alloc] initWithFrame:attachmentFrame
                                                                              characterIndex:range.location];
        
        [attachments addObject:value];
        [attachmentInfos addObject:attachmentInfo];
    }];
    
    if (attachments.count > 0) {
        return [[MPITextAttachmentsInfo alloc] initWithAttachments:attachments attachmentInfos:attachmentInfos];
    }
    
    return nil;
}

- (void)drawImageAttchmentsWithAttachmentsInfo:(MPITextAttachmentsInfo *)attachmentsInfo
                                       atPoint:(CGPoint)origin
                               inTextContainer:(NSTextContainer *)textContainer {
    if (!attachmentsInfo || attachmentsInfo.attachments.count == 0) {
        return;
    }
    
    NSArray *attachments = attachmentsInfo.attachments;
    NSArray *attachmentInfos = attachmentsInfo.attachmentInfos;
    
    [attachments enumerateObjectsUsingBlock:^(MPITextAttachment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPITextAttachmentInfo *attachmentInfo = attachmentInfos[idx];
        CGRect frame = attachmentInfo.frame;
        NSUInteger characterIndex = attachmentInfo.characterIndex;
        frame.origin.x += origin.x;
        frame.origin.y += origin.y;
        id content = obj.content;
        if ([content isKindOfClass:UIImage.class]) {
            [obj drawAttachmentInTextContainer:textContainer
                             textView:nil
                                  proposedRect:frame
                                characterIndex:characterIndex];
        }
    }];
}

- (void)drawViewAndLayerAttchmentsWithAttachmentsInfo:(MPITextAttachmentsInfo *)attachmentsInfo
                                              atPoint:(CGPoint)origin
                                      inTextContainer:(NSTextContainer *)textContainer
                                             textView:(UIView *)textView {
    if (!attachmentsInfo || attachmentsInfo.attachments.count == 0 || !textView) {
        return;
    }
    
    NSAssert([NSThread mainThread], @"Drawing view and layer must be on main thread.");
    NSArray *attachments = attachmentsInfo.attachments;
    NSArray *attachmentInfos = attachmentsInfo.attachmentInfos;
    
    [attachments enumerateObjectsUsingBlock:^(MPITextAttachment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MPITextAttachmentInfo *attachmentInfo = attachmentInfos[idx];
        CGRect frame = attachmentInfo.frame;
        NSUInteger characterIndex = attachmentInfo.characterIndex;
        frame.origin.x += origin.x;
        frame.origin.y += origin.y;
        id content = obj.content;
        if ([content isKindOfClass:UIView.class] ||
            [content isKindOfClass:CALayer.class]) {
            [obj drawAttachmentInTextContainer:textContainer
                                      textView:textView
                                  proposedRect:frame
                                characterIndex:characterIndex];
        }
    }];
}

#pragma mark - Debug

- (void)drawDebugWithDebugOption:(MPITextDebugOption *)op forGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)point {
    if (!op || ![op needsDrawDebug]) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextSetLineWidth(context, 1.0 / MPITextScreenScale());
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    [self enumerateLineFragmentsForGlyphRange:glyphsToShow usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        if (op.lineFragmentFillColor) {
            [op.lineFragmentFillColor setFill];
            CGContextAddRect(context, MPITextCGRectPixelRound(rect));
            CGContextFillPath(context);
        }
        if (op.lineFragmentBorderColor) {
            [op.lineFragmentBorderColor setStroke];
            CGContextAddRect(context, MPITextCGRectPixelHalf(rect));
            CGContextStrokePath(context);
        }
        if (op.lineFragmentUsedFillColor) {
            [op.lineFragmentUsedFillColor setFill];
            CGContextAddRect(context, MPITextCGRectPixelRound(usedRect));
            CGContextFillPath(context);
        }
        if (op.lineFragmentUsedBorderColor) {
            [op.lineFragmentUsedBorderColor setStroke];
            CGContextAddRect(context, MPITextCGRectPixelHalf(usedRect));
            CGContextStrokePath(context);
        }
        if (op.baselineColor) {
            CGFloat baselineOffset = [self baselineOffsetForGlyphRange:glyphRange];
            [op.baselineColor setStroke];
            CGFloat x1 = MPITextCGFloatPixelHalf(usedRect.origin.x);
            CGFloat x2 = MPITextCGFloatPixelHalf(usedRect.origin.x + usedRect.size.width);
            CGFloat y =  MPITextCGFloatPixelHalf(CGRectGetMinY(rect) + baselineOffset);
            CGContextMoveToPoint(context, x1, y);
            CGContextAddLineToPoint(context, x2, y);
            CGContextStrokePath(context);
        }
        if (op.glyphFillColor || op.glyphBorderColor) {
            for (NSUInteger g = 0; g < glyphRange.length; g++) {
                CGRect glyphRect = [self glyphRectForGlyphIndex:glyphRange.location + g inTextContainer:textContainer];
                
                if (op.glyphFillColor) {
                    [op.glyphFillColor setFill];
                    CGContextAddRect(context, MPITextCGRectPixelRound(glyphRect));
                    CGContextFillPath(context);
                }
                if (op.glyphBorderColor) {
                    [op.glyphBorderColor setStroke];
                    CGContextAddRect(context, MPITextCGRectPixelHalf(glyphRect));
                    CGContextStrokePath(context);
                }
            }
        }
    }];
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

- (CGFloat)baselineOffsetForGlyphIndex:(NSUInteger)glyphIndex {
    NSRange glyphRange;
    [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&glyphRange];
    return [self baselineOffsetForGlyphRange:glyphRange];
}

- (CGFloat)baselineOffsetForGlyphRange:(NSRange)glyphRange {
    NSUInteger maxRange = NSMaxRange(glyphRange);
    NSUInteger index = glyphRange.location;
    CGGlyph glyph = kCGFontIndexInvalid;
    while (glyph == kCGFontIndexInvalid && index < maxRange) {
        glyph = [self CGGlyphAtIndex:index];
        index++;
    }
    
    NSUInteger glyphIndex = index - 1;
    CGFloat baselineOffset = [self locationForGlyphAtIndex:glyphIndex].y;
    
    if (glyph == kCGFontIndexInvalid) {
        NSUInteger charIndex = [self characterIndexForGlyphAtIndex:glyphIndex];
        UIFont *font = [self.textStorage attribute:NSFontAttributeName
                                           atIndex:charIndex
                                    effectiveRange:NULL];
        return baselineOffset + font.descender;
    }
    
    return baselineOffset;
}

- (CGRect)glyphRectForGlyphIndex:(NSUInteger)glyphIndex inTextContainer:(NSTextContainer *)textContainer {
    NSUInteger charIndex = [self characterIndexForGlyphAtIndex:glyphIndex];
    CGGlyph glyph = [self CGGlyphAtIndex:glyphIndex];
    CTFontRef font = (__bridge_retained CTFontRef)[self.textStorage attribute:NSFontAttributeName
                                                                      atIndex:charIndex
                                                               effectiveRange:NULL];
    if (font == nil) {
        font = (__bridge_retained CTFontRef)[UIFont systemFontOfSize:MPITextCoreTextDefaultFontSize()];
    }
    //                                    Glyph Advance
    //                             +-------------------------+
    //                             |                         |
    //                             |                         |
    // +------------------------+--|-------------------------|--+-----------+-----+ What TextKit returns sometimes
    // |                        |  |             XXXXXXXXXXX +  |           |     | (approx. correct height, but
    // |               ---------|--+---------+  XXX       XXXX +|-----------|-----|  sometimes inaccurate bounding
    // |               |        |             XXX          XXXXX|           |     |  widths)
    // |               |        |             XX             XX |           |     |
    // |               |        |            XX                 |           |     |
    // |               |        |           XXX                 |           |     |
    // |               |        |           XX                  |           |     |
    // |               |        |      XXXXXXXXXXX              |           |     |
    // |   Cap Height->|        |          XX                   |           |     |
    // |               |        |          XX                   |  Ascent-->|     |
    // |               |        |          XX                   |           |     |
    // |               |        |          XX                   |           |     |
    // |               |        |          X                    |           |     |
    // |               |        |          X                    |           |     |
    // |               |        |          X                    |           |     |
    // |               |        |         XX                    |           |     |
    // |               |        |         X                     |           |     |
    // |               ---------|-------+ X +-------------------------------------|
    // |                        |        XX                     |                 |
    // |                        |        X                      |                 |
    // |                        |      XX         Descent------>|                 |
    // |                        | XXXXXX                        |                 |
    // |                        |  XXX                          |                 |
    // +------------------------+-------------------------------------------------+
    //                                                          |
    //                                                          +--+Actual bounding box
    
    CGFloat advance = CTFontGetAdvancesForGlyphs(font, kCTFontOrientationHorizontal, &glyph, NULL, 1);
    CGFloat ascent = CTFontGetAscent(font);
    CGFloat descent = CTFontGetDescent(font);
    
    CFRelease(font);
    
    // Textkit's glyphs count not equal CoreText glyphs count, and the CoreText removed glyphs if glyph == 0. It's means the glyph not suitable for font.
    if (glyph == 0 && glyphIndex > 0) {
        return [self glyphRectForGlyphIndex:glyphIndex - 1 inTextContainer:textContainer];
    }
    
    CGRect glyphRect = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];
    
    // If it is a NSTextAttachment(glyph == kCGFontIndexInvalid), we don't have the matched glyph and use width of glyphRect instead of advance.
    CGFloat lineHeight = (glyph == kCGFontIndexInvalid) ? glyphRect.size.height : ascent + descent;
    CGPoint location = [self locationForGlyphAtIndex:glyphIndex];
    CGRect lineFragmentRect = [self lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    CGFloat baseline = location.y + CGRectGetMinY(lineFragmentRect);
    
    CGRect properGlyphRect;
    // We are just measuring the line heights here, so we can use the
    // heights used by TextKit, which tend to be pretty good.
    properGlyphRect = CGRectMake(CGRectGetMinX(lineFragmentRect) + location.x,
                                 (glyph == kCGFontIndexInvalid) ? CGRectGetMinY(glyphRect) : baseline - ascent,
                                 (glyph == kCGFontIndexInvalid) ? CGRectGetWidth(glyphRect) : advance,
                                 lineHeight);
    return properGlyphRect;
}

- (NSUInteger)numberOfLinesInTextContainer:(NSTextContainer *)textContainer {
    NSRange glyphRange, lineRange = NSMakeRange(0, 0);
    CGRect rect;
    CGFloat lastOriginY = -1.0;
    NSUInteger numberOfLines = -1;
    
    glyphRange = [self glyphRangeForTextContainer:textContainer];
    while (lineRange.location < NSMaxRange(glyphRange)) {
        rect = [self lineFragmentRectForGlyphAtIndex:lineRange.location effectiveRange:&lineRange];
        if (CGRectGetMinY(rect) > lastOriginY) {
            numberOfLines++;
        }
        lastOriginY = CGRectGetMinY(rect);
        lineRange.location = NSMaxRange(lineRange);
    }
    
    return numberOfLines;
}

@end
