//
//  MPITextKitRender.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPITextRenderAttributes;
@class MPITextAttachmentsInfo;
@class MPITextBackgroundsInfo;
@class MPITextDebugOption;
@class MPITextSelectionRect;

NS_ASSUME_NONNULL_BEGIN

@interface MPITextRenderer : NSObject

@property (nonatomic, strong, readonly) MPITextRenderAttributes *renderAttributes;
@property (nonatomic, assign, readonly) CGSize constrainedSize;

/**
 Stored attachments info and it's useful for drawing.
 */
@property (nullable, nonatomic, strong, readonly) MPITextAttachmentsInfo *attachmentsInfo;

- (instancetype)initWithRenderAttributes:(MPITextRenderAttributes *)renderAttributes
                         constrainedSize:(CGSize)constrainedSize;

/**
 The render's size.
 */
- (CGSize)size;

/**
 Whether or not the text is truncated.
 */
- (BOOL)isTruncated;

/// The text truncation range if text if truncated.
- (NSRange)truncationRange;

/**
 Draw everything without view and layer for given point.

 @param point The point indicates where to start drawing.
 @param debugOption How to drawing debug.
 */
- (void)drawAtPoint:(CGPoint)point debugOption:(nullable MPITextDebugOption *)debugOption;

/**
 It's must be on main thread.

 @param point Draw view and layer for given point.
 @param referenceTextView NSAttachment will be drawed to it.
 */
- (void)drawViewAndLayerAtPoint:(CGPoint)point referenceTextView:(UIView *)referenceTextView;

@end

@interface MPITextRenderer (MPITextKitExtendedRenderer)

/**
 Returns the value for the attribute with a given name of the character at a given index, and by reference the range over which the attribute applies.
 
 @param name The name of an attribute.
 @param point The index at which to test for attributeName.
 @param effectiveRange If the named attribute does not exist at index, the range is (NSNotFound, 0).
 @param inTruncation Indicates the attribute is in truncation.
 @return Returns The value for the attribute named attributeName of the character at index, or nil if there is no such attribute.
 */
- (nullable id)attribute:(NSAttributedStringKey)name
                 atPoint:(CGPoint)point
          effectiveRange:(nullable NSRangePointer)effectiveRange
            inTruncation:(nullable BOOL *)inTruncation;

/// Returns the index of the character for  the given  point. Returns NSNotFound if index in truncation.
/// @param point The character's point.
- (NSUInteger)characterIndexForPoint:(CGPoint)point;

/// Return the range for the text enclosing a character index in a text word unit.
/// @param characterIndex  The character for which to return the range.
- (NSRange)rangeEnclosingCharacterForIndex:(NSUInteger)characterIndex;

/**
 Returns an array of selection rects corresponding to the range of text.
 The start and end rect can be used to show grabber.
 
 @param characterRange The characterRangefor which to return selection rectangles.
 @return An array of `MPITextSelectionRect` objects that encompass the selection.
 If not found, the array is empty.
 */
- (NSArray<MPITextSelectionRect *> *)selectionRectsForCharacterRange:(NSRange)characterRange;

/// Returns the rect for the line fragment.
/// @param characterIndex The character for which to return the line fragment rectangle.
/// @param effectiveCharacterRange If not NULL, on output, the range for all chracters in the line fragment.
- (CGRect)lineFragmentUsedRectForCharacterAtIndex:(NSUInteger)characterIndex effectiveRange:(nullable NSRangePointer)effectiveCharacterRange;

/// Returns the rect for the line used fragment.
/// @param characterIndex The character for which to return the line fragment rectangle.
/// @param effectiveCharacterRange If not NULL, on output, the range for all chracters in the line fragment.
- (CGRect)lineFragmentRectForCharacterAtIndex:(NSUInteger)characterIndex effectiveRange:(nullable NSRangePointer)effectiveCharacterRange;

@end

NS_ASSUME_NONNULL_END
