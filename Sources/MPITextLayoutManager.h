//
//  MPITextLayoutManager.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MPITextAttachmentsInfo;
@class MPITextBackgroundsInfo;
@class MPITextDebugOption;

@interface MPITextLayoutManager : NSLayoutManager

/**
 Returns a single bounding rectangle (in container coordinates) enclosing glyph and other marks drawn in the given text container for the given glyph index, not including glyph that draw outside their line fragment rectangles and text attributes such as underlining.

 @param glyphIndex The index of the glyph for which to return the associated bounding rect.
 @param textContainer The text container in which the glyphs are laid out.
 @return The bounding rectangle enclosing the given glyph index.
 */
- (CGRect)glyphRectForGlyphIndex:(NSUInteger)glyphIndex inTextContainer:(NSTextContainer *)textContainer;

/**
 If the given glyph does not have an explicit location set for it (for example, if it is part of (but not first in) a sequence of nominally spaced characters), the baselineOffset is calculated by glyph advancements from the location of the most recent preceding glyph with a location set.
 Glyph baselineOffset are relative to their line fragment rectangle's origin. The line fragment rectangle in turn is defined in the coordinate system of the text container where it resides.
 This method causes glyph generation and layout for the line fragment containing the specified glyph, or if noncontiguous layout is not enabled, up to and including that line fragment.

 @param glyphIndex The glyph index.
 @return The baselineOffset for given glyphs range.
 */
- (CGFloat)baselineOffsetForGlyphIndex:(NSUInteger)glyphIndex;

/**
 Detect number of lines in text container.

 @param textContainer The text container which for detecting.
 @return The lines counts.
 */
- (NSUInteger)numberOfLinesInTextContainer:(NSTextContainer *)textContainer;

- (nullable MPITextBackgroundsInfo *)backgroundsInfoForGlyphRange:(NSRange)glyphsToShow
                                                     inTextContainer:(NSTextContainer *)textContainer;

- (nullable MPITextAttachmentsInfo *)attachmentsInfoForGlyphRange:(NSRange)glyphsToShow
                                                     inTextContainer:(NSTextContainer *)textContainer;

- (void)drawBackgroundWithBackgroundsInfo:(MPITextBackgroundsInfo *)backgroundsInfo
                                  atPoint:(CGPoint)origin;

- (void)drawImageAttchmentsWithAttachmentsInfo:(MPITextAttachmentsInfo *)attachmentsInfo
                                       atPoint:(CGPoint)origin
                               inTextContainer:(NSTextContainer *)textContainer;

- (void)drawViewAndLayerAttchmentsWithAttachmentsInfo:(MPITextAttachmentsInfo *)attachmentsInfo
                                              atPoint:(CGPoint)origin
                                      inTextContainer:(NSTextContainer *)textContainer
                                             textView:(UIView *)textView;

- (void)drawDebugWithDebugOption:(MPITextDebugOption *)debugOption
                   forGlyphRange:(NSRange)glyphsToShow
                         atPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END


