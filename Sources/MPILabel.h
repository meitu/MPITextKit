//
//  MPILabel.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextAttributes.h>
#import <MPITextKit/MPITextRenderAttributes.h>
#import <MPITextKit/MPITextRenderer.h>
#import <MPITextKit/MPITextDebugOption.h>
#else
#import "MPITextAttributes.h"
#import "MPITextRenderAttributes.h"
#import "MPITextRenderer.h"
#import "MPITextDebugOption.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol MPILabelDelegate;


/// Composed by truncationAttributedToken and additionalTruncationAttributedMessage.
/// @param attributedText The current styled text.
/// @param token The truncation token string used when text is truncated.
/// @param additionalMessage The second attributed string appended for truncation.
FOUNDATION_EXPORT
NSAttributedString *MPITextTruncationAttributedTextWithTokenAndAdditionalMessage(NSAttributedString * _Nullable attributedText,
                                                                                 NSAttributedString * _Nullable token,
                                                                                 NSAttributedString * _Nullable additionalMessage);

/**
 Calculate the text view size. This method can warms up the cache.
 And background thread usage supported.

 @param attributes The text attributes.
 @param fitsSize The text fits size.
 @param textContainerInset The textContainer insets.
 @return Suggest text view size.
 */
FOUNDATION_EXPORT
CGSize MPITextSuggestFrameSizeForAttributes(MPITextRenderAttributes *attributes,
                                            CGSize fitsSize,
                                            UIEdgeInsets textContainerInset);

@interface MPILabel : UIView

/** The receiver’s delegate. */
@property (nullable, nonatomic, weak) id<MPILabelDelegate> delegate;

/** `NSAttributedString` attributes applied to links when touched.*/
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *highlightedLinkTextAttributes;

#pragma mark - Accessing the Text Attributes
///=============================================================================
/// @name Accessing the Text Attributes
///=============================================================================

/**
 The underlying attributed string drawn by the label.
 NOTE: If set, the label ignores other properties.
 */
@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

/**
 Ignore common properties (such as text, font, textColor, attributedText...) and
 only use the text renderer to display content.
 
 Set it to get higher performance.
 */
@property (nullable, nonatomic, strong) MPITextRenderer *textRenderer;

/**
 The text displayed by the label. Default is nil.
 Set a new value to this property also replaces the text in `attributedText`.
 Get the value returns the plain text in `attributedText`.
 */
@property (nullable, nonatomic, copy) NSString *text;

/**
 The font of the text. Default is 17-point system font.
 Set a new value to this property also causes the new font to be applied to the entire `attributedText`.
 */
@property (null_resettable, nonatomic, strong) UIFont *font;

/**
 The color of the text. Default is black.
 Set a new value to this property also causes the new color to be applied to the entire `attributedText`.
 */
@property (null_resettable, nonatomic, strong) UIColor *textColor;

/**
 The shadow color of the text. Default is nil.
 Set a new value to this property also causes the shadow color to be applied to the entire `attributedText`.
 */
@property (nullable, nonatomic, strong) UIColor *shadowColor;

/**
 The shadow offset of the text. Default is CGSizeMake(0, -1) -- a top shadow.
 Set a new value to this property also causes the shadow offset to be applied to the entire `attributedText`.
 */
@property (nonatomic) CGSize shadowOffset;

/**
 The shadow blur of the text. Default is 0.
 Set a new value to this property also causes the shadow blur to be applied to the entire `attributedText`.
 */
@property (nonatomic) CGFloat shadowBlurRadius;

/**
 The technique to use for aligning the text. Default is NSTextAlignmentLeft.
 Set a new value to this property also causes the new alignment to be applied to the entire `attributedText`.
 */
@property (nonatomic) NSTextAlignment textAlignment;

/**
 The text vertical aligmnent in container. Default is MPITextVerticalAlignmentCenter.
 */
@property (nonatomic) MPITextVerticalAlignment textVerticalAlignment;

/**
 The technique to use for wrapping and truncating the label's text.
 Default is NSLineBreakByTruncatingTail.
 
 Notice: Currently, only tail is supported for truncating.
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 The truncation token string used when text is truncated. Default is nil.
 When the value is nil, the label use "…" as default truncation token.
 */
@property (nullable, nonatomic, strong) NSAttributedString *truncationAttributedToken;

/**
 @summary The second attributed string appended for truncation.
 @discussion This string will be highlighted on touches.
 @default nil
 */
@property (nullable, nonatomic, strong) NSAttributedString *additionalTruncationAttributedMessage;

/**
 Composed by truncationAttributedToken and additionalTruncationAttributedMessage.
 */
@property (null_resettable, nonatomic, readonly) NSAttributedString *truncationAttributedText;

/**
Whether or not the text is truncated. It's expensive if text not rendered.
*/
@property (nonatomic, readonly, getter=isTruncated) BOOL truncated;

/// The text truncation range if text if truncated.
@property (nonatomic, readonly) NSRange truncationRange;

/**
 The maximum number of lines to use for rendering text. Default value is 1.
 0 means no limit.
 */
@property (nonatomic) NSInteger numberOfLines;

#pragma mark - Configuring the Text Selection

/// Toggle selectability, which controls the ability of the user to select content
/// Note: You can change the selection's style with tintColor.
@property(nonatomic, getter=isSelectable) BOOL selectable;

/// The current selection range of the receiver.  
@property(nonatomic) NSRange selectedRange;

#pragma mark - Configuring the Text Container
///=============================================================================
/// @name Configuring the Text Container
///=============================================================================

/**
 The inset of the text container's layout area within the text view's content area.
 Default value is UIEdgeInsetsZero.
 */
@property (nonatomic) UIEdgeInsets textContainerInset;

/**
 An array of UIBezierPath representing the exclusion paths inside the receiver's bounding rect.
 The default value is empty.
 */
@property (nullable, nonatomic, copy) NSArray<UIBezierPath *> *exclusionPaths;

/**
 The debug option to display CoreText layout result.
 The default value is [MPITextDebugOption sharedDebugOption].
 */
@property (nullable, nonatomic, copy) MPITextDebugOption *debugOption;

#pragma mark - Getting the Layout Constraints
///=============================================================================
/// @name Getting the Layout Constraints
///=============================================================================

/**
 The preferred maximum width (in points) for a multiline label.
 
 @discussion Support for constraint-based layout (auto layout).
 If nonzero, this is used when determining -intrinsicContentSize for multiline labels.
 
 NOTE: It's contains textContainerInset.
 */
@property (nonatomic) CGFloat preferredMaxLayoutWidth;

#pragma mark - Configuring the Display Mode
///=============================================================================
/// @name Configuring the Display Mode
///=============================================================================

/**
 A Boolean value indicating whether the layout and rendering codes are running
 asynchronously on background threads.
 
 The default value is `NO`.
 */
@property (nonatomic) BOOL displaysAsynchronously;

/**
 If the value is YES, and the layer is rendered asynchronously, then it will
 set label.layer.contents to nil before display.
 
 The default value is `YES`.
 
 @discussion When the asynchronously display is enabled, the layer's content will
 be updated after the background render process finished. If the render process
 can not finished in a vsync time (1/60 second), the old content will be still kept
 for display. You may manually clear the content by set the layer.contents to nil
 after you update the label's properties, or you can just set this property to YES.
 */
@property (nonatomic) BOOL clearContentsBeforeAsynchronouslyDisplay;

/**
 If the value is NO, and the layer is rendered asynchronously, then it will add
 a fade animation on layer when the contents of layer changed.
 
 The default value is `YES`.
 */
@property (nonatomic) BOOL fadeOnAsynchronouslyDisplay;

/// To show menu by selectedRange.
- (void)showMenu;

/// To hide menu.
- (void)hideMenu;

@end

@protocol MPILabelDelegate <NSObject>

@optional

/**
 Asks the delegate if the specified text view should allow the specified type of user interaction with the given URL in the given range of text.

 @param label Reference label.
 @param link MPITextLink instance.
 @param attributedText The attributedText, if link in truncation, it's truncationAttributedText.
 @param characterRange Current interactive characterRange.
 @return YES if interaction with the URL should be allowed; NO if interaction should not be allowed.
 */
- (BOOL)label:(MPILabel *)label shouldInteractWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange;

/**
 User Interacted link.
 
 @param label Reference label.
 @param link MPITextLink instance.
 @param attributedText The attributedText, if link in truncation, it's truncationAttributedText.
 @param characterRange Current interactive characterRange.
 @param interaction Interaction type.
 */
- (void)label:(MPILabel *)label didInteractWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange interaction:(MPITextItemInteraction)interaction;

/**
 Asks the delegate if the specified text should have another attributes when highlighted.
 
 @param label Reference label.
 @param link MPITextLink instance.
 @param attributedText The attributedText, if link in truncation, it's truncationAttributedText.
 @param characterRange  Current interactive characterRange。
 */
- (nullable NSDictionary *)label:(MPILabel *)label highlightedTextAttributesWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange;

/// The text view will begin selection triggered by longpress.
/// @param label  Reference label.
/// @param selectedRange Selection of text.
- (void)labelWillBeginSelection:(MPILabel *)label selectedRange:(NSRangePointer)selectedRange;

/// The menu items will be used by menu. If  menu items is empty, menu will not be shown.
/// @param label Reference Label.
- (nullable NSArray<__kindof UIMenuItem *> *)menuItemsForLabel:(MPILabel *)label;

/// The visibility of the menu.
/// @param label  Reference Label.
- (BOOL)menuVisibleForLabel:(MPILabel *)label;

/// Customize menu showing. You should implement menuVisibleForLabel:.
/// @param label Reference label.
/// @param menuItems The custom menu items for the menu.
/// @param targetRect A rectangle that defines the area that is to be the target of the menu commands.
- (void)label:(MPILabel *)label showMenuWithMenuItems:(NSArray<UIMenuItem *> *)menuItems targetRect:(CGRect)targetRect;

/// Customize menu hiding.
/// @param label Reference label.
- (void)labelHideMenu:(MPILabel *)label;

@end

NS_ASSUME_NONNULL_END
