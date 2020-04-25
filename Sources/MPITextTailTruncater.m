//
//  MPITextTailTruncater.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextTailTruncater.h"
#import "MPITextKitContext.h"
#import "MPITextRenderer.h"
#import "MPITextRenderAttributes.h"
#import "MPITextKitConst.h"

@interface MPITextTailTruncater ()

@property (nonatomic, strong) NSAttributedString *truncationAttributedString;
@property (nonatomic, strong) NSCharacterSet *avoidTailTruncationSet;
@property (nonatomic, strong) NSValue *truncationUsedRectValue;

@end

@implementation MPITextTailTruncater

- (instancetype)initWithTruncationAttributedString:(NSAttributedString *)truncationAttributedString
                            avoidTailTruncationSet:(NSCharacterSet *)avoidTailTruncationSet
{
    if (self = [super init]) {
        _truncationAttributedString = truncationAttributedString;
        _avoidTailTruncationSet = avoidTailTruncationSet;
    }
    return self;
}

/**
 Calculates the intersection of the truncation message within the end of the last line.
 */
- (NSUInteger)_calculateCharacterIndexBeforeTruncationMessage:(NSLayoutManager *)layoutManager
                                                  textStorage:(NSTextStorage *)textStorage
                                                textContainer:(NSTextContainer *)textContainer
{
    NSRange visibleGlyphRange = [layoutManager glyphRangeForBoundingRect:(CGRect){ .size = textContainer.size }
                                                         inTextContainer:textContainer];
    
    NSUInteger lastVisibleGlyphIndex = NSMaxRange(visibleGlyphRange) - 1;
    if (lastVisibleGlyphIndex < 0) {
        return NSNotFound;
    }
    
    NSRange lastLineRange;
    CGRect lastLineRect = [layoutManager lineFragmentRectForGlyphAtIndex:lastVisibleGlyphIndex
                                                          effectiveRange:&lastLineRange];
    
    CGRect constrainedRect = (CGRect){ .size = textContainer.size };
    CGRect lastLineUsedRect = [layoutManager lineFragmentUsedRectForGlyphAtIndex:lastVisibleGlyphIndex
                                                                  effectiveRange:NULL];
    
    NSUInteger lastVisibleCharacterIndex = [layoutManager characterIndexForGlyphAtIndex:lastVisibleGlyphIndex];
    if (lastVisibleCharacterIndex >= textStorage.length) {
        return NSNotFound;
    }

    NSParagraphStyle *paragraphStyle = [textStorage attribute:NSParagraphStyleAttributeName atIndex:lastVisibleCharacterIndex effectiveRange:NULL];
    
    // We assume LTR so long as the writing direction is not
    BOOL rtlWritingDirection = paragraphStyle ? paragraphStyle.baseWritingDirection == NSWritingDirectionRightToLeft : NO;
    // We only want to treat the truncation rect as left-aligned in the case that we are right-aligned and our writing
    // direction is RTL.
    BOOL leftAligned = CGRectGetMinX(lastLineRect) == CGRectGetMinX(lastLineUsedRect) || !rtlWritingDirection;
    
    if (!_truncationUsedRectValue) {
        CGRect truncationUsedRect =
        [_truncationAttributedString boundingRectWithSize:MPITextContainerMaxSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
        _truncationUsedRectValue = [NSValue valueWithCGRect:truncationUsedRect];
    }
    CGRect truncationUsedRect = _truncationUsedRectValue.CGRectValue;
    CGFloat truncationOriginX = (leftAligned ?
                                 CGRectGetMaxX(constrainedRect) - truncationUsedRect.size.width :
                                 CGRectGetMinX(constrainedRect));
    CGRect translatedTruncationRect = CGRectMake(truncationOriginX,
                                                 CGRectGetMinY(lastLineRect),
                                                 truncationUsedRect.size.width,
                                                 truncationUsedRect.size.height);
    
    // Determine which glyph is the first to be clipped / overlaps the truncation message.
    CGFloat truncationMessageX = (leftAligned ?
                                  CGRectGetMinX(translatedTruncationRect) :
                                  CGRectGetMaxX(translatedTruncationRect));
    CGPoint beginningOfTruncationMessage = CGPointMake(truncationMessageX,
                                                       CGRectGetMidY(translatedTruncationRect));
    NSUInteger firstClippedGlyphIndex = [layoutManager glyphIndexForPoint:beginningOfTruncationMessage
                                                          inTextContainer:textContainer
                                           fractionOfDistanceThroughGlyph:NULL];
    
    // If it didn't intersect with any text then it should just return the last visible character index, since the
    // truncation rect can fully fit on the line without clipping any other text.
    if (firstClippedGlyphIndex == NSNotFound) {
        return [layoutManager characterIndexForGlyphAtIndex:lastVisibleGlyphIndex];
    }
    NSUInteger firstCharacterIndexToReplace = [layoutManager characterIndexForGlyphAtIndex:firstClippedGlyphIndex];
    
    // Break on word boundaries
    return [self _findTruncationInsertionPointAtOrBeforeCharacterIndex:firstCharacterIndexToReplace
                                                         layoutManager:layoutManager
                                                           textStorage:textStorage];
}

/**
 Finds the first whitespace at or before the character index do we don't truncate in the middle of words
 If there are multiple whitespaces together (say a space and a newline), this will backtrack to the first one
 */
- (NSUInteger)_findTruncationInsertionPointAtOrBeforeCharacterIndex:(NSUInteger)firstCharacterIndexToReplace
                                                      layoutManager:(NSLayoutManager *)layoutManager
                                                        textStorage:(NSTextStorage *)textStorage
{
    // Don't attempt to truncate beyond the end of the string
    if (firstCharacterIndexToReplace >= textStorage.length) {
        return 0;
    }
    
    NSRange rangeOfLastVisibleAvoidedChars = { .location = NSNotFound };
    if (_avoidTailTruncationSet) {
        // Find the glyph range of the line fragment containing the first character to replace.
        NSRange lineGlyphRange;
        [layoutManager lineFragmentRectForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:firstCharacterIndexToReplace]
                                        effectiveRange:&lineGlyphRange];
        
        // Look for the first whitespace from the end of the line, starting from the truncation point
        NSUInteger startingSearchIndex = [layoutManager characterIndexForGlyphAtIndex:lineGlyphRange.location];
        NSUInteger endingSearchIndex = firstCharacterIndexToReplace;
        NSRange rangeToSearch = NSMakeRange(startingSearchIndex, (endingSearchIndex - startingSearchIndex));
        
        rangeOfLastVisibleAvoidedChars = [textStorage.string rangeOfCharacterFromSet:_avoidTailTruncationSet
                                                                             options:NSBackwardsSearch
                                                                               range:rangeToSearch];
    }
    
    // Couldn't find a good place to truncate. Might be because there is no whitespace in the text, or we're dealing
    // with a foreign language encoding. Settle for truncating at the original place, which may be mid-word.
    if (rangeOfLastVisibleAvoidedChars.location == NSNotFound) {
        return firstCharacterIndexToReplace;
    } else {
        return rangeOfLastVisibleAvoidedChars.location;
    }
}

- (MPITextTruncationInfo *)truncateWithLayoutManager:(MPITextLayoutManager *)layoutManager
                                         textStorage:(NSTextStorage *)textStorage
                                       textContainer:(NSTextContainer *)textContainer {
    NSUInteger originalStringLength = textStorage.length;
    
    if (originalStringLength == 0) {
        return nil;
    }
    
    NSRange visibleGlyphRange = [layoutManager glyphRangeForBoundingRect:(CGRect){ .size = textContainer.size }
                                                         inTextContainer:textContainer];
    NSRange visibleCharacterRange = [layoutManager characterRangeForGlyphRange:visibleGlyphRange actualGlyphRange:NULL];
    
    // Check if text is truncated, and if so apply our truncation string
    if (visibleCharacterRange.length < originalStringLength && _truncationAttributedString.length > 0) {
        NSUInteger firstCharacterIndexToReplace = [self _calculateCharacterIndexBeforeTruncationMessage:layoutManager
                                                                                            textStorage:textStorage
                                                                                          textContainer:textContainer];
        if (firstCharacterIndexToReplace == 0 || firstCharacterIndexToReplace == NSNotFound) {
            return nil;
        }
        
        // Update/truncate the visible range of text
        visibleCharacterRange = NSMakeRange(visibleCharacterRange.location, firstCharacterIndexToReplace - visibleCharacterRange.location);
        
        NSRange truncationReplacementRange = NSMakeRange(firstCharacterIndexToReplace, originalStringLength - firstCharacterIndexToReplace);
        
        // Replace the end of the visible message with the truncation string
        [textStorage replaceCharactersInRange:truncationReplacementRange
                         withAttributedString:_truncationAttributedString];
        
        NSValue *truncationCharacterRange = [NSValue valueWithRange:NSMakeRange(firstCharacterIndexToReplace, _truncationAttributedString.length)];
        NSArray *visibleCharacterRanges = @[[NSValue valueWithRange:visibleCharacterRange]];
        return [[MPITextTruncationInfo alloc] initWithTruncationCharacterRange:truncationCharacterRange
                                                           visibleCharacterRanges:visibleCharacterRanges];
    }
    
    return nil;
}

@end

