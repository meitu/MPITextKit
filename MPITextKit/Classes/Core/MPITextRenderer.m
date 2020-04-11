//
//  MPITextRenderer.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextRenderer.h"
#import "MPITextKitContext.h"
#import "MPITextRenderAttributes.h"
#import "MPITextAttachmentsInfo.h"
#import "MPITextBackgroundsInfo.h"
#import "MPITextRendererKey.h"
#import "MPITextTailTruncater.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextCache.h"
#import "MPITextKitConst.h"
#import "MPITextInput.h"

static MPITextCache *sharedTruncaterCache()
{
    static dispatch_once_t onceToken;
    static MPITextCache *truncaterCache = nil;
    dispatch_once(&onceToken, ^{
        truncaterCache = [[MPITextCache alloc] init];
        truncaterCache.countLimit = 200;
    });
    return truncaterCache;
}

static id<MPITextTruncating> truncaterForRenderAttributes(MPITextRenderAttributes *renderAttributes) {
    // Currently only tail is supported.
    if (renderAttributes.lineBreakMode != NSLineBreakByTruncatingTail) {
        return nil;
    }
    
    MPITextCache *cache = sharedTruncaterCache();
    
    MPITextRendererKey *key = [[MPITextRendererKey alloc] initWithAttributes:renderAttributes constrainedSize:MPITextContainerMaxSize];
    
    id<MPITextTruncating> truncater = [cache objectForKey:key];
    if (truncater == nil) {
        if (renderAttributes.lineBreakMode == NSLineBreakByTruncatingTail) {
            truncater = [[MPITextTailTruncater alloc] initWithTruncationAttributedString:renderAttributes.attributedText avoidTailTruncationSet:MPITextDefaultAvoidTruncationCharacterSet()];
        }
        if (truncater) {
            [cache setObject:truncater forKey:key];
        }
    }
    
    return truncater;
}

@interface MPITextRenderer ()

@property (nonatomic, strong) MPITextKitContext *context;

@property (nonatomic, assign) CGSize calculatedSize;

@property (nonatomic, strong) MPITextTruncationInfo *truncationInfo;

@property (nonatomic, strong) MPITextAttachmentsInfo *attachmentsInfo;
@property (nonatomic, strong) MPITextBackgroundsInfo *backgroundsInfo;

@property (nonatomic, assign) NSRange glyphsToShow;

@end

@implementation MPITextRenderer

- (instancetype)initWithRenderAttributes:(MPITextRenderAttributes *)renderAttributes constrainedSize:(CGSize)constrainedSize {
    self = [super init];
    if (self) {
        _renderAttributes = renderAttributes;
        _constrainedSize = constrainedSize;
        
        // TextKit render incorrect by truncating. eg. text = @"/a/n/n/nb", maximumNumberOfLines = 2.
        NSLineBreakMode lineBreakMode = renderAttributes.lineBreakMode;
        if (lineBreakMode == NSLineBreakByTruncatingTail) {
            lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        _context = [[MPITextKitContext alloc] initWithAttributedString:renderAttributes.attributedText
                                                         lineBreakMode:lineBreakMode
                                                  maximumNumberOfLines:renderAttributes.maximumNumberOfLines
                                                        exclusionPaths:renderAttributes.exclusionPaths
                                                       constrainedSize:constrainedSize];
        
        [self calculateSize];
        [self caclulateGlyphsToShow];
        [self calculateExtraInfos];
        
    }
    return self;
}

- (void)calculateSize {
    __block CGRect boundingRect;
    __block MPITextTruncationInfo *truncationInfo = nil;
    MPITextRenderAttributes *renderAttributes = self.renderAttributes;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        [layoutManager ensureLayoutForTextContainer:textContainer];
        boundingRect = [layoutManager usedRectForTextContainer:textContainer];
        
        MPITextRenderAttributesBuilder *truncationRenderAttributesBuilder = [MPITextRenderAttributesBuilder new];
        truncationRenderAttributesBuilder.attributedText = renderAttributes.truncationAttributedText;
        truncationRenderAttributesBuilder.lineBreakMode = renderAttributes.lineBreakMode;
        MPITextRenderAttributes *truncationRenderAttributes = [[MPITextRenderAttributes alloc] initWithBuilder:truncationRenderAttributesBuilder];
        
        id<MPITextTruncating> truncater = truncaterForRenderAttributes(truncationRenderAttributes);
        if (truncater) {
            truncationInfo =
            [truncater truncateWithLayoutManager:layoutManager
                                     textStorage:textStorage
                                   textContainer:textContainer];
            if (truncationInfo) {
                [layoutManager ensureLayoutForTextContainer:textContainer];
                CGRect truncatedBoundingRect = [layoutManager usedRectForTextContainer:textContainer];

                // We should use the maximum height.
                boundingRect.size.height = MAX(CGRectGetHeight(truncatedBoundingRect), CGRectGetHeight(boundingRect));
            }
        }
    }];
    
    // TextKit often returns incorrect glyph bounding rects in the horizontal direction, so we clip to our bounding rect
    // to make sure our width calculations aren't being offset by glyphs going beyond the constrained rect.
    boundingRect.size = CGSizeMake(ceil(boundingRect.size.width), ceil(boundingRect.size.height));
    boundingRect = CGRectIntersection(boundingRect, (CGRect){.size = self.constrainedSize});
    
    CGSize size = boundingRect.size;
    
    // Update textContainer's size if needed.
    CGSize newConstrainedSize = self.constrainedSize;
    if (self.constrainedSize.width > MPITextContainerMaxSize.width - FLT_EPSILON) {
        newConstrainedSize.width = size.width;
    }
    if (self.constrainedSize.height > MPITextContainerMaxSize.height - FLT_EPSILON) {
        newConstrainedSize.height = size.height;
    }
    
    if (!CGSizeEqualToSize(newConstrainedSize, self.constrainedSize)) {
        [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
            textContainer.size = newConstrainedSize;
            [layoutManager ensureLayoutForTextContainer:textContainer];
        }];
    }
    
    self.calculatedSize = size;
    self.truncationInfo = truncationInfo;
}

- (void)caclulateGlyphsToShow {
    __block NSRange glyphsToShow;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        glyphsToShow = [layoutManager glyphRangeForTextContainer:textContainer];
    }];
    
    self.glyphsToShow = glyphsToShow;
}

- (void)calculateExtraInfos {
    __block MPITextAttachmentsInfo *attachmentsInfo = nil;
    __block MPITextBackgroundsInfo *backgroundsInfo = nil;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        NSRange glyphsToShow = [layoutManager glyphRangeForTextContainer:textContainer];
        if (glyphsToShow.location != NSNotFound) {
            attachmentsInfo = [layoutManager attachmentsInfoForGlyphRange:glyphsToShow
                                                          inTextContainer:textContainer];
            
            backgroundsInfo = [layoutManager backgroundsInfoForGlyphRange:glyphsToShow
                                                          inTextContainer:textContainer];
        }
    }];
    
    self.attachmentsInfo = attachmentsInfo;
    self.backgroundsInfo = backgroundsInfo;
}

- (CGSize)size {
    return self.calculatedSize;
}

- (BOOL)isTruncated {
    return self.truncationInfo != nil;
}

- (NSRange)truncationRange {
    if (self.isTruncated) {
        return [self.truncationInfo.truncationCharacterRange rangeValue];
    }
    return NSMakeRange(NSNotFound, 0);
}

- (MPITextRenderAttributes *)copyRenderAttributes {
    return self.renderAttributes.copy;
}

- (void)drawAtPoint:(CGPoint)point debugOption:(MPITextDebugOption *)debugOption {
    NSRange glyphsToShow = self.glyphsToShow;
    MPITextAttachmentsInfo *attachmentsInfo = self.attachmentsInfo;
    MPITextBackgroundsInfo *backgroundsInfo = self.backgroundsInfo;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        if (glyphsToShow.location != NSNotFound) {
            [layoutManager drawBackgroundForGlyphRange:glyphsToShow atPoint:point];
            if (backgroundsInfo) {
                [layoutManager drawBackgroundWithBackgroundsInfo:backgroundsInfo atPoint:point];
            }
            [layoutManager drawGlyphsForGlyphRange:glyphsToShow atPoint:point];
            if (attachmentsInfo) {
                [layoutManager drawImageAttchmentsWithAttachmentsInfo:attachmentsInfo
                                                              atPoint:point
                                                      inTextContainer:textContainer];
            }
            if (debugOption) {
                [layoutManager drawDebugWithDebugOption:debugOption
                                          forGlyphRange:glyphsToShow
                                                atPoint:point];
            }
        }
    }];
}

- (void)drawViewAndLayerAtPoint:(CGPoint)point referenceTextView:(UIView *)referenceTextView {
    NSRange glyphsToShow = self.glyphsToShow;
    MPITextAttachmentsInfo *attachmentsInfo = self.attachmentsInfo;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        if (glyphsToShow.location != NSNotFound) {
            [layoutManager drawViewAndLayerAttchmentsWithAttachmentsInfo:attachmentsInfo
                                                                 atPoint:point
                                                         inTextContainer:textContainer
                                                                textView:referenceTextView];
        }
    }];
}

@end

@implementation MPITextRenderer (MPITextKitExtendedRenderer)

- (nullable id)attribute:(NSAttributedStringKey)name
                 atPoint:(CGPoint)point
          effectiveRange:(nullable NSRangePointer)effectiveRange
            inTruncation:(BOOL *)pInTruncation {
    __block id value = nil;
    __block NSRange attributeRange = NSMakeRange(NSNotFound, 0);
    __block BOOL inTruncation;
    NSValue *truncationCharacterRange = self.truncationInfo.truncationCharacterRange;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        // Find the range.
        NSRange visibleGlyphsRange = [layoutManager glyphRangeForBoundingRect:(CGRect){ .size = textContainer.size }
                                                              inTextContainer:textContainer];
        NSRange visibleCharactersRange = [layoutManager characterRangeForGlyphRange:visibleGlyphsRange actualGlyphRange:NULL];
        NSUInteger glyphIndex =  [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
        if (glyphIndex != NSNotFound) {
            CGRect glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];
            if (CGRectContainsPoint(glyphRect, point)) {
                NSUInteger characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
                value = [textStorage attribute:name atIndex:characterIndex longestEffectiveRange:&attributeRange inRange:visibleCharactersRange];
                if (!value) {
                    attributeRange = NSMakeRange(NSNotFound, 0);
                }
            }
        }
        
        // Check that the range is in truncation.
        if (truncationCharacterRange &&
            NSLocationInRange(attributeRange.location, truncationCharacterRange.rangeValue)) {
            inTruncation = YES;
            attributeRange = NSMakeRange(attributeRange.location - truncationCharacterRange.rangeValue.location, attributeRange.length);
        } else {
            inTruncation = NO;
        }
    }];
    
    if (effectiveRange) {
        *effectiveRange = attributeRange;
    }
    
    if (pInTruncation) {
        *pInTruncation = inTruncation;
    }
    
    return value;
}

- (NSUInteger)characterIndexForPoint:(CGPoint)point {
    __block NSUInteger characterIndex = NSNotFound;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        NSUInteger glyphIndex =  [layoutManager glyphIndexForPoint:point inTextContainer:textContainer];
        if (glyphIndex != NSNotFound) {
            characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        }
    }];
    
    if (self.isTruncated) {
        if (NSLocationInRange(characterIndex, self.truncationRange)) {
            return NSNotFound;
        }
    }
    return characterIndex;
}

- (NSRange)rangeEnclosingCharacterForIndex:(NSUInteger)characterIndex {
    __block NSString *text = nil;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        text = textStorage.string;
    }];
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    CFStringRef string = (__bridge CFStringRef)(text);
    CFRange range = CFRangeMake(0, text.length);
    CFOptionFlags flag = kCFStringTokenizerUnitWord;
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, range, flag, locale);
    CFStringTokenizerTokenType tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    
    while (tokenType != kCFStringTokenizerTokenNone) {
        CFRange currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        if (currentTokenRange.location <= characterIndex &&
            currentTokenRange.location + currentTokenRange.length > characterIndex) {
            resultRange = NSMakeRange(currentTokenRange.location, currentTokenRange.length);
            break;
        }
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    }
    
    CFRelease(tokenizer);
    CFRelease(locale);
    
    if (resultRange.location == NSNotFound) {
        resultRange = NSMakeRange(characterIndex, 1);
    }
    return resultRange;
}

- (NSArray<MPITextSelectionRect *> *)selectionRectsForCharacterRange:(NSRange)characterRange {
    NSMutableArray<MPITextSelectionRect *> *selectionRects = [NSMutableArray new];
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:NULL];
        [layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange withinSelectedGlyphRange:glyphRange inTextContainer:textContainer usingBlock:^(CGRect rect, BOOL *stop) {
            NSUInteger startGlyphIndex = [layoutManager glyphIndexForPoint:CGPointMake(ceil(CGRectGetMinX(rect)), CGRectGetMidY(rect)) inTextContainer:textContainer];
            NSUInteger startCharacterIndex = [layoutManager characterIndexForGlyphAtIndex:startGlyphIndex];
            NSParagraphStyle *paragraphStyle = [textStorage attribute:NSParagraphStyleAttributeName atIndex:startCharacterIndex effectiveRange:NULL];
            MPITextSelectionRect *selectionRect = [MPITextSelectionRect new];
            selectionRect.rect = rect;
            selectionRect.writingDirection = paragraphStyle ? paragraphStyle.baseWritingDirection : NSWritingDirectionLeftToRight;
            selectionRect.isVertical = textContainer.layoutOrientation == NSTextLayoutOrientationVertical;
            [selectionRects addObject:selectionRect];
        }];
    }];
    if (selectionRects.count > 0) {
        MPITextSelectionRect *startSelectionRect = selectionRects[0];
        startSelectionRect.containsStart = YES;
        MPITextSelectionRect *endSelectionRect = selectionRects[selectionRects.count - 1];
        endSelectionRect.containsEnd = YES;
    }
    return selectionRects.copy;
}

- (CGRect)lineFragmentUsedRectForCharacterAtIndex:(NSUInteger)characterIndex effectiveRange:(nullable NSRangePointer)effectiveCharacterRange {
    __block CGRect lineFragmentUsedRect = CGRectZero;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:characterIndex];
        NSRange effectiveGlyphRange;
        lineFragmentUsedRect = [layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:&effectiveGlyphRange];
        if (effectiveCharacterRange) {
            *effectiveCharacterRange = [layoutManager characterRangeForGlyphRange:effectiveGlyphRange actualGlyphRange:NULL];
        }
    }];
    return lineFragmentUsedRect;
}

- (CGRect)lineFragmentRectForCharacterAtIndex:(NSUInteger)characterIndex effectiveRange:(nullable NSRangePointer)effectiveCharacterRange {
    __block CGRect lineFragmentRect = CGRectZero;
    [self.context performBlockWithLockedTextKitComponents:^(MPITextLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        NSUInteger glyphIndex = [layoutManager glyphIndexForCharacterAtIndex:characterIndex];
        NSRange effectiveGlyphRange;
        lineFragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:&effectiveGlyphRange];
        if (effectiveCharacterRange) {
            *effectiveCharacterRange = [layoutManager characterRangeForGlyphRange:effectiveGlyphRange actualGlyphRange:NULL];
        }
    }];
    return lineFragmentRect;
}

@end
