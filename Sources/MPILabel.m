//
//  MPILabel.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPILabel.h"
#import "MPITextSelectionView.h"
#import "MPITextAsyncLayer.h"
#import "MPITextRendererKey.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextAttachmentsInfo.h"
#import "MPITextCache.h"
#import "MPITextInteractionManager.h"

#import "NSMutableAttributedString+MPITextKit.h"
#import "NSAttributedString+MPITextKit.h"

static dispatch_queue_t MPITextLabelGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

static MPITextCache *sharedRendererCache()
{
    static dispatch_once_t onceToken;
    static MPITextCache *rendererCache = nil;
    dispatch_once(&onceToken, ^{
        rendererCache = [[MPITextCache alloc] init];
        rendererCache.countLimit = 500;
    });
    return rendererCache;
}

static MPITextCache *sharedTextSizeCache()
{
    static dispatch_once_t onceToken;
    static MPITextCache *textViewSizeCache = nil;
    dispatch_once(&onceToken, ^{
        textViewSizeCache = [[MPITextCache alloc] init];
        textViewSizeCache.countLimit = 1000;
    });
    return textViewSizeCache;
}

static MPITextRenderer *rendererForAttributes(MPITextRenderAttributes *attributes, CGSize constrainedSize) {
    if (constrainedSize.width < FLT_EPSILON ||
        constrainedSize.height < FLT_EPSILON) {
        return nil;
    }
    MPITextRendererKey *key = [[MPITextRendererKey alloc] initWithAttributes:attributes constrainedSize:constrainedSize];
    
    MPITextCache *cache = sharedRendererCache();
    
    MPITextRenderer *renderer = [cache objectForKey:key];
    if (renderer == nil) {
        renderer = [[MPITextRenderer alloc] initWithRenderAttributes:attributes constrainedSize:constrainedSize];
        [cache setObject:renderer forKey:key];
    }
    
    return renderer;
}

static void cacheRenderer(MPITextRenderer *renderer, MPITextRenderAttributes *attributes, CGSize constrainedSize) {
    MPITextCache *cache = sharedRendererCache();
    
    MPITextRendererKey *key = [[MPITextRendererKey alloc] initWithAttributes:attributes constrainedSize:constrainedSize];
    
    [cache setObject:renderer forKey:key];
}

static NSValue *textSizeForKey(MPITextRendererKey *key) {
    MPITextCache *cache = sharedTextSizeCache();
    
    return [cache objectForKey:key];
}

static void cacheTextSizeForKey(MPITextRendererKey *key, CGSize textSize) {
    MPITextCache *cache = sharedTextSizeCache();
    
    [cache setObject:[NSValue valueWithCGSize:textSize] forKey:key];
}

NSAttributedString *MPITextPrepareTruncationTextForDrawing(NSAttributedString *attributedText, NSAttributedString *truncationText) {
    NSMutableAttributedString *truncationMutableString = truncationText.mutableCopy;
    // Grab the attributes from the full string
    if (attributedText.length > 0) {
        NSAttributedString *originalString = attributedText;
        NSInteger originalStringLength = originalString.length;
        // Add any of the original string's attributes to the truncation string,
        // but don't overwrite any of the truncation string's attributes
        NSDictionary *originalStringAttributes = [originalString attributesAtIndex:originalStringLength - 1 effectiveRange:NULL];
        [truncationText enumerateAttributesInRange:NSMakeRange(0, truncationText.length) options:0 usingBlock:
         ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
             NSMutableDictionary *futureTruncationAttributes = [originalStringAttributes mutableCopy];
             [futureTruncationAttributes addEntriesFromDictionary:attributes];
             [truncationMutableString setAttributes:futureTruncationAttributes range:range];
         }];
    }
    return truncationMutableString;
}

NSAttributedString *MPITextTruncationAttributedTextWithTokenAndAdditionalMessage(NSAttributedString *attributedText,
                                                                                 NSAttributedString *token,
                                                                                 NSAttributedString *additionalMessage) {
    NSAttributedString *truncationAttributedText = nil;
    if (token != nil && additionalMessage != nil) {
        NSMutableAttributedString *newComposedTruncationString = [[NSMutableAttributedString alloc] initWithAttributedString:token];
        [newComposedTruncationString appendAttributedString:additionalMessage];
        truncationAttributedText = newComposedTruncationString;
    } else if (token != nil) {
        truncationAttributedText = token;
    } else if (additionalMessage != nil) {
        truncationAttributedText = additionalMessage;
    } else {
        truncationAttributedText = MPITextDefaultTruncationAttributedToken();
    }
    truncationAttributedText = MPITextPrepareTruncationTextForDrawing(attributedText, truncationAttributedText);
    return truncationAttributedText;
}

CGSize MPITextSuggestFrameSizeForAttributes(MPITextRenderAttributes *attributes,
                                            CGSize fitsSize,
                                            UIEdgeInsets textContainerInset) {
    if (attributes.attributedText.length == 0) {
        return CGSizeZero;
    }
    
    if (fitsSize.width < FLT_EPSILON || fitsSize.width > MPITextContainerMaxSize.width) {
        fitsSize.width = MPITextContainerMaxSize.width;
    }
    if (fitsSize.height < FLT_EPSILON || fitsSize.height > MPITextContainerMaxSize.width) {
        fitsSize.height = MPITextContainerMaxSize.height;
    }
    
    CGFloat horizontalValue = MPITextUIEdgeInsetsGetHorizontalValue(textContainerInset);
    CGFloat verticalValue = MPITextUIEdgeInsetsGetVerticalValue(textContainerInset);
    
    CGSize constrainedSize = fitsSize;
    if (constrainedSize.width < MPITextContainerMaxSize.width - FLT_EPSILON) {
        constrainedSize.width = fitsSize.width - horizontalValue;
    }
    if (constrainedSize.height < MPITextContainerMaxSize.height - FLT_EPSILON) {
        constrainedSize.height = fitsSize.height - verticalValue;
    }
    
    MPITextRendererKey *key = [[MPITextRendererKey alloc] initWithAttributes:attributes constrainedSize:constrainedSize];
    
    MPITextRenderer *renderer = nil;
    CGSize textSize = CGSizeZero;
    NSValue *textSizeValue = textSizeForKey(key);
    if (textSizeValue) {
        textSize = textSizeValue.CGSizeValue;
    } else {
        renderer = [[MPITextRenderer alloc] initWithRenderAttributes:attributes constrainedSize:constrainedSize];
        textSize = renderer.size;
        
        cacheTextSizeForKey(key, textSize);
    }
    
    CGSize suggestSize = CGSizeMake(textSize.width + horizontalValue, textSize.height + verticalValue);
    
    if (suggestSize.width > fitsSize.width) {
        suggestSize.width = fitsSize.width;
    }
    if (suggestSize.height > fitsSize.height) {
        suggestSize.height = fitsSize.height;
    }
    
    if (renderer) {
        // Cache Renderer for render.
        if (constrainedSize.width > MPITextContainerMaxSize.width - FLT_EPSILON) {
            constrainedSize.width = textSize.width;
        }
        if (constrainedSize.height > MPITextContainerMaxSize.height - FLT_EPSILON) {
            constrainedSize.height = textSize.height;
        }
        cacheRenderer(renderer, attributes, constrainedSize);
    }
    
    return suggestSize;
}

static CGFloat const kAsyncFadeDuration = 0.08; // Time in seconds for async display fadeout animation.
static NSString *const kAsyncFadeAnimationKey = @"contents";

@interface MPILabel () <
    MPITextAsyncLayerDelegate,
    MPITextInteractionManagerDelegate,
    MPITextInteractable,
    MPITextDebugTarget
> {
    struct {
        unsigned int contentsUpdated : 1;
        unsigned int attachmentsNeedsUpdate : 1;
    } _state;
}

@property (nonatomic, strong) MPITextInteractionManager *interactionManager;

@property(nonatomic, strong) MPITextSelectionView *selectionView;

@property (nonatomic, strong) NSMutableArray<UIView *> *attachmentViews;
@property (nonatomic, strong) NSMutableArray<CALayer *> *attachmentLayers;

@property (nonatomic, assign) MPITextMenuType menuType;

@end

@implementation MPILabel
@synthesize truncationAttributedText = _truncationAttributedText;

- (void)dealloc {
#ifdef DEBUG
    [MPITextDebugOption removeDebugTarget:self];
#endif
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _interactionManager = [[MPITextInteractionManager alloc] initWithInteractableView:self];
    _interactionManager.delegate = self;
    
    self.layer.contentsScale = MPITextScreenScale();
    self.contentMode = UIViewContentModeRedraw;
    self.opaque = NO;
    
    _highlightedLinkTextAttributes = MPITextDefaultHighlightedLinkTextAttributes();
    
    _selectable = NO;
    _selectedRange = NSMakeRange(NSNotFound, 0);
    
    _clearContentsBeforeAsynchronouslyDisplay = YES;
    _fadeOnAsynchronouslyDisplay = YES;
    _displaysAsynchronously = NO;
    
    _numberOfLines = 1;
    _lineBreakMode = NSLineBreakByTruncatingTail;
    _textAlignment = NSTextAlignmentLeft;
    _textVerticalAlignment = MPITextVerticalAlignmentCenter;
    _shadowOffset = CGSizeMake(0, -1);
    
    _attachmentViews = [NSMutableArray new];
    _attachmentLayers = [NSMutableArray new];
    
#ifdef DEBUG
    _debugOption = [MPITextDebugOption sharedDebugOption];
    [MPITextDebugOption addDebugTarget:self];
#endif
}

#pragma mark - Override

+ (Class)layerClass {
    return [MPITextAsyncLayer class];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = CGRectGetWidth(self.frame);
    if (self.numberOfLines == 1) {
        width = MPITextContainerMaxSize.width;
    }
    
    CGFloat preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;
    if (preferredMaxLayoutWidth > FLT_EPSILON) {
        width = preferredMaxLayoutWidth;
    }
    
    return [self sizeThatFits:CGSizeMake(width, MPITextContainerMaxSize.height)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.textRenderer) {
        return CGSizeMake(self.textRenderer.size.width +
                          MPITextUIEdgeInsetsGetHorizontalValue(self.textContainerInset),
                          self.textRenderer.size.height +
                          MPITextUIEdgeInsetsGetVerticalValue(self.textContainerInset));
    }
    
    MPITextRenderAttributes *renderAttributes = [self renderAttributes];
    if (CGSizeEqualToSize(self.bounds.size, size)) { // sizeToFit called.
        size.height = MPITextContainerMaxSize.height;
    }
    return MPITextSuggestFrameSizeForAttributes(renderAttributes, size, self.textContainerInset);
}

- (void)setBounds:(CGRect)bounds {
    // https://stackoverflow.com/questions/17491376/ios-autolayout-multi-line-uilabel
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [self invalidate];
    }
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    CGSize newSize = self.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [self invalidate];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.selectionView) {
        self.selectionView.frame = self.bounds;
    }
}

#pragma mark - Responder

- (BOOL)canBecomeFirstResponder {
    if (!self.isSelectable) {
        return NO;
    }
    return YES;
}

- (BOOL)resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    if (result) {
        [self hideMenu];
    }
    return result;
}

#pragma mark - UIAccessibility

- (NSString *)accessibilityLabel {
    return self.text;
}

- (NSAttributedString *)accessibilityAttributedLabel {
    return self.attributedText;
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(nullable id)sender {
    NSString *string = [self.attributedText mpi_plainTextForRange:self.selectedRange];
    if (string.length > 0) {
        [UIPasteboard generalPasteboard].string = string;
    }
}

#pragma mark - Rendering

- (void)clearContentsIfNeeded {
    if (!self.layer.contents) {
        return;
    }
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(MPITextLabelGetReleaseQueue(), ^{
            CFRelease(image);
        });
    }
}

- (void)clearAttachmentViewsAndLayers {
    for (UIView *view in self.attachmentViews) {
        if (view.superview == self) {
            [view removeFromSuperview];
        }
    }
    for (CALayer *layer in self.attachmentLayers) {
        if (layer.superlayer == self.layer) {
            [layer removeFromSuperlayer];
        }
    }
    [self.attachmentViews removeAllObjects];
    [self.attachmentLayers removeAllObjects];
}

- (void)clearAttachmentViewsAndLayersWithAttachmetsInfo:(MPITextAttachmentsInfo *)attachmentsInfo {
    for (UIView *view in self.attachmentViews) {
        if (view.superview == self &&
            ![self containsContent:view forAttachmetsInfo:attachmentsInfo]) {
            [view removeFromSuperview];
        }
    }
    for (CALayer *layer in self.attachmentLayers) {
        if (layer.superlayer == self.layer &&
            ![self containsContent:layer forAttachmetsInfo:attachmentsInfo]) {
            [layer removeFromSuperlayer];
        }
    }
    [self.attachmentViews removeAllObjects];
    [self.attachmentLayers removeAllObjects];
}

- (BOOL)containsContent:(id)content forAttachmetsInfo:(MPITextAttachmentsInfo *)attachmentsInfo {
    BOOL contains = NO;
    for (MPITextAttachment *attachment in attachmentsInfo.attachments) {
        if (attachment.content == content) {
            contains = YES;
            break;
        }
    }
    return contains;
}

- (void)setNeedsUpdateContents {
    if (self.displaysAsynchronously && self.clearContentsBeforeAsynchronouslyDisplay) {
        [self clearContentsIfNeeded];
    }
    
    [self setNeedsUpdateContentsWithoutClearContents];
}

- (void)setNeedsUpdateContentsWithoutClearContents {
    _state.contentsUpdated = NO;
    [self.layer setNeedsDisplay];
}

- (void)invalidateTruncationAttributedText {
    _truncationAttributedText = nil;
}

- (void)invalidateAttachments {
    _state.attachmentsNeedsUpdate = YES;
}

- (void)invalidate {
    [self invalidateAttachments];
    [self invalidateIntrinsicContentSize];
    [self invalidateTruncationAttributedText];
    [self setNeedsUpdateContents];
}

- (void)updateAttributedTextAttribute:(NSAttributedStringKey)name
                                value:(id)value {
    NSMutableAttributedString *attributedText = self.attributedText.mutableCopy;
    if (name) {
        [attributedText mpi_setAttribute:name value:value range:attributedText.mpi_rangeOfAll];
    }
    _attributedText = attributedText.copy;
    
    [self setNeedsUpdateContents];
    
    if ([name isEqualToString:NSFontAttributeName]) {
        [self invalidateAttachments];
        [self invalidateTruncationAttributedText];
        [self invalidateIntrinsicContentSize];
    }
}

- (MPITextRenderAttributes *)renderAttributes {
    BOOL hasActiveLink = self.interactionManager.hasActiveLink;
    BOOL activeInTruncation = self.interactionManager.activeInTruncation;
    NSAttributedString *highlightedAttributedText = self.interactionManager.highlightedAttributedText;
    
    MPITextRenderAttributesBuilder *attributesBuilder = nil;
    if (self.textRenderer) {
        attributesBuilder = [[MPITextRenderAttributesBuilder alloc] initWithRenderAttributes:self.textRenderer.renderAttributes];
        if (hasActiveLink) {
            if (!activeInTruncation) {
                attributesBuilder.attributedText = highlightedAttributedText;
            } else {
                attributesBuilder.truncationAttributedText = highlightedAttributedText;
            }
        }
    } else {
        attributesBuilder = [MPITextRenderAttributesBuilder new];
        attributesBuilder.lineBreakMode = self.lineBreakMode;
        attributesBuilder.maximumNumberOfLines = self.numberOfLines;
        attributesBuilder.exclusionPaths = self.exclusionPaths;
        if (hasActiveLink && !activeInTruncation) {
            attributesBuilder.attributedText = highlightedAttributedText;
        } else {
            attributesBuilder.attributedText = self.attributedText;
        }
        if (hasActiveLink && activeInTruncation) {
            attributesBuilder.truncationAttributedText = highlightedAttributedText;
        } else {
           attributesBuilder.truncationAttributedText = self.truncationAttributedText;
        }
    }
    return [attributesBuilder build];
}

- (MPITextRenderer *)currentRenderer {
    MPITextRenderer *renderer = nil;
    BOOL hasActiveLink = self.interactionManager.hasActiveLink;
    if (self.textRenderer) {
        CGSize textContainerSize = self.textRenderer.constrainedSize;
        if (hasActiveLink) {
            MPITextRenderAttributes *renderAttributes = [self renderAttributes];
            renderer = [[MPITextRenderer alloc] initWithRenderAttributes:renderAttributes constrainedSize:textContainerSize];
        } else {
            renderer = self.textRenderer;
        }
    } else {
        MPITextRenderAttributes *renderAttributes = [self renderAttributes];
        CGSize textContainerSize = [self calculateTextContainerSize];
        if (hasActiveLink) {
            renderer = [[MPITextRenderer alloc] initWithRenderAttributes:renderAttributes constrainedSize:textContainerSize];
        } else {
            renderer = rendererForAttributes(renderAttributes, textContainerSize);
        }
    }
    return renderer;
}

#pragma mark - Geometry

- (CGSize)calculateTextContainerSize {
    CGRect frame = UIEdgeInsetsInsetRect(self.frame, self.textContainerInset);
    CGSize constrainedSize = frame.size;
    return constrainedSize;
}

- (CGRect)textRectForBounds:(CGRect)bounds textSize:(CGSize)textSize {
    CGRect textRect = UIEdgeInsetsInsetRect(bounds, self.textContainerInset);
    
    if (textSize.height < textRect.size.height) {
        CGFloat yOffset = 0.0f;
        switch (self.textVerticalAlignment) {
            case MPITextVerticalAlignmentCenter:
                yOffset = (textRect.size.height - textSize.height) / 2.0f;
                break;
            case MPITextVerticalAlignmentBottom:
                yOffset = textRect.size.height - textSize.height;
                break;
            case MPITextVerticalAlignmentTop:
            default:
                break;
        }
        textRect.origin.y += yOffset;
    }
    
    return textRect;
}

- (CGPoint)convertPointToTextKit:(CGPoint)point forBounds:(CGRect)bounds textSize:(CGSize)textSize {
    CGRect textRect = [self textRectForBounds:bounds textSize:textSize];
    point.x -= textRect.origin.x;
    point.y -= textRect.origin.y;
    return point;
}

- (CGPoint)convertPointFromTextKit:(CGPoint)point forBounds:(CGRect)bounds textSize:(CGSize)textSize {
    CGRect textRect = [self textRectForBounds:bounds textSize:textSize];
    point.x += textRect.origin.x;
    point.y += textRect.origin.y;
    return point;
}

- (CGRect)convertRectFromTextKit:(CGRect)rect forBounds:(CGRect)bounds textSize:(CGSize)textSize {
    CGRect textRect = [self textRectForBounds:bounds textSize:textSize];
    rect = CGRectOffset(rect, textRect.origin.x, textRect.origin.y);
    return rect;
}

#pragma mark - Text Selection

- (void)updateSelectionView {
    if (!self.selectionView) {
        return;
    }
    NSRange selectedRange = self.selectedRange;
    
    self.selectionView.hidden = !self.isSelectable || selectedRange.location == NSNotFound;
    if (self.selectionView.isHidden) {
        return;
    }
    
    MPITextRenderer *renderer = [self currentRenderer];
    NSArray<MPITextSelectionRect *> *selectionRects = [renderer selectionRectsForCharacterRange:selectedRange];
    [selectionRects enumerateObjectsUsingBlock:^(MPITextSelectionRect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.rect = [self convertRectFromTextKit:obj.rect forBounds:self.bounds textSize:renderer.size];
    }];
    
    CGFloat startGrabberHeight;
    if (selectionRects.count > 1) {
        CGRect startLineFragmentRect = [renderer lineFragmentRectForCharacterAtIndex:selectedRange.location effectiveRange:NULL];
        startGrabberHeight = CGRectGetHeight(startLineFragmentRect);
    } else {
        CGRect startLineFragmentUsedRect = [renderer lineFragmentUsedRectForCharacterAtIndex:selectedRange.location effectiveRange:NULL];
        startGrabberHeight = CGRectGetHeight(startLineFragmentUsedRect);
    }
    CGRect endLineFragmentUsedRect = [renderer lineFragmentUsedRectForCharacterAtIndex:NSMaxRange(selectedRange) - 1 effectiveRange:NULL];
    [self.selectionView updateSelectionRects:selectionRects
                          startGrabberHeight:startGrabberHeight
                            endGrabberHeight:CGRectGetHeight(endLineFragmentUsedRect)];
}

#pragma mark - Defalut Values

- (UIFont *)defalutFont {
    return [UIFont systemFontOfSize:17];
}

- (UIColor *)defalutTextColor {
    return [UIColor blackColor];
}

#pragma mark - Attributes

- (NSDictionary *)attributesByProperties {
    UIFont *font = self.font ? : [self defalutFont];
    UIColor *textColor = self.textColor ? : [self defalutTextColor];
    NSShadow *shadow = [self shadowByProperties];
    NSMutableDictionary *attributes = [@{NSForegroundColorAttributeName: textColor,
                                         NSFontAttributeName: font} mutableCopy];
    attributes[NSShadowAttributeName] = shadow;
    return [attributes copy];
}

- (NSShadow *)shadowByProperties {
    NSShadow *shadow = nil;
    if (self.shadowColor &&
        self.shadowBlurRadius > FLT_EPSILON) {
        shadow = [NSShadow new];
        shadow.shadowColor = self.shadowColor;
        shadow.shadowOffset = self.shadowOffset;
        shadow.shadowBlurRadius = self.shadowBlurRadius;
    }
    return shadow;
}

#pragma mark - MPITextInteractable

- (BOOL)shouldInteractLinkWithLinkRange:(NSRange)linkRange
                      forAttributedText:(NSAttributedString *)attributedText {
    BOOL shouldInteractLink = YES;
    if ([self.delegate respondsToSelector:@selector(label:shouldInteractWithLink:forAttributedText:inRange:)]) {
        id value = [attributedText attribute:MPITextLinkAttributeName atIndex:linkRange.location effectiveRange:NULL];
        if (value) {
            shouldInteractLink = [self.delegate label:self shouldInteractWithLink:value forAttributedText:attributedText inRange:linkRange];
        } else {
            shouldInteractLink = NO;
        }
    }
    return shouldInteractLink;
}

- (NSDictionary<NSString *,id> *)highlightedLinkTextAttributesWithLinkRange:(NSRange)linkRange
                                                          forAttributedText:(NSAttributedString *)attributedText {
    NSDictionary *textAttributes = self.highlightedLinkTextAttributes;
    if ([self.delegate respondsToSelector:@selector(label:highlightedTextAttributesWithLink:forAttributedText:inRange:)]) {
        id value = [attributedText attribute:MPITextLinkAttributeName atIndex:linkRange.location effectiveRange:NULL];
        NSDictionary *attributes = [self.delegate label:self highlightedTextAttributesWithLink:value forAttributedText:attributedText inRange:linkRange];
        if (attributes) {
            textAttributes = attributes;
        }
    }
    return textAttributes;
}

- (void)tapLinkWithLinkRange:(NSRange)linkRange forAttributedText:(NSAttributedString *)attributedText {
    if ([self.delegate respondsToSelector:@selector(label:didInteractWithLink:forAttributedText:inRange:interaction:)]) {
        id value = [attributedText attribute:MPITextLinkAttributeName atIndex:linkRange.location effectiveRange:NULL];
        [self.delegate label:self didInteractWithLink:value forAttributedText:attributedText inRange:linkRange interaction:MPITextItemInteractionTap];
    }
}

- (void)longPressLinkWithLinkRange:(NSRange)linkRange forAttributedText:(NSAttributedString *)attributedText {
    if ([self.delegate respondsToSelector:@selector(label:didInteractWithLink:forAttributedText:inRange:interaction:)]) {
        id value = [attributedText attribute:MPITextLinkAttributeName atIndex:linkRange.location effectiveRange:NULL];
        [self.delegate label:self didInteractWithLink:value forAttributedText:attributedText inRange:linkRange interaction:MPITextItemInteractionLongPress];
    }
}

- (NSRange)linkRangeAtPoint:(CGPoint)point inTruncation:(nullable BOOL *)inTruncation {
    if (!_state.contentsUpdated) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    MPITextRenderer *renderer = [self currentRenderer];
    
    point = [self convertPointToTextKit:point forBounds:self.bounds textSize:renderer.size];
    
    NSRange linkRange;
#ifdef DEBUG
    MPITextLink *link =
#endif
    [renderer attribute:MPITextLinkAttributeName atPoint:point effectiveRange:&linkRange inTruncation:inTruncation];
#ifdef DEBUG
    if (linkRange.location != NSNotFound) {
        NSAssert([link isKindOfClass:MPITextLink.class], @"The value for MPITextLinkAttributeName must be of type MPITextLink.");
    }
#endif
    return linkRange;
}

- (BOOL)selectionAtPoint:(CGPoint)point {
    if (!self.selectionView) {
        return NO;
    }
    if (self.selectionView.isHidden) {
        return NO;
    }
    return [self.selectionView isSelectionRectsContainsPoint:point] || [self.selectionView isGrabberContainsPoint:point];
}

- (MPITextSelectionGrabberType)grabberTypeAtPoint:(CGPoint)point {
    MPITextSelectionGrabberType grabberTpye = MPITextSelectionGrabberTypeNone;
    if ([self.selectionView isStartGrabberContainsPoint:point]) {
        grabberTpye = MPITextSelectionGrabberTypeStart;
    } else if ([self.selectionView isEndGrabberContainsPoint:point]) {
        grabberTpye = MPITextSelectionGrabberTypeEnd;
    }
    return grabberTpye;
}

- (CGRect)grabberRectForGrabberType:(MPITextSelectionGrabberType)grabberType {
    if (grabberType == MPITextSelectionGrabberTypeStart) {
        return self.selectionView.startGrabber.frame;
    } else if (grabberType == MPITextSelectionGrabberTypeEnd) {
        return self.selectionView.endGrabber.frame;
    }
    return CGRectZero;
}

- (NSUInteger)characterIndexForPoint:(CGPoint)point {
    MPITextRenderer *renderer = [self currentRenderer];
    point = [self convertPointToTextKit:point forBounds:self.bounds textSize:renderer.size];
    return [renderer characterIndexForPoint:point];
}

- (void)beginSelectionAtPoint:(CGPoint)point; {
    MPITextRenderer *renderer = [self currentRenderer];
    point = [self convertPointToTextKit:point forBounds:self.bounds textSize:renderer.size];
    NSUInteger characterIndex = [renderer characterIndexForPoint:point];
    if (characterIndex == NSNotFound) {
        return;
    }
    
    NSRange selectedRange = [renderer rangeEnclosingCharacterForIndex:characterIndex];
    if (selectedRange.location == NSNotFound) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(labelWillBeginSelection:selectedRange:)]) {
        [self.delegate labelWillBeginSelection:self selectedRange:&selectedRange];
    }
    
    self.selectedRange = selectedRange;
    
    [self becomeFirstResponder];
    
    [self showMenu];
}

- (void)updateSelectionWithRange:(NSRange)range {
    self.selectedRange = range;
}

- (void)endSelection {
    self.selectedRange = NSMakeRange(NSNotFound, 0);
    
    [self resignFirstResponder];
    
    [self hideMenu];
}

- (BOOL)isMenuVisible {
    if (self.menuType == MPITextMenuTypeSystem) {
        return UIMenuController.sharedMenuController.isMenuVisible;
    } else if (self.menuType == MPITextMenuTypeCustom) {
        return [self.delegate menuVisibleForLabel:self];
    }
    return NO;
}

- (void)showMenu {
    NSArray<UIMenuItem *> *menuItems = nil;
    if ([self.delegate respondsToSelector:@selector(menuItemsForLabel:)]) {
        menuItems = [self.delegate menuItemsForLabel:self];
        if (menuItems.count == 0) {
            return;
        }
    }
    
    if (!self.isFirstResponder) {
        [self becomeFirstResponder];
    }
    
    __block CGRect targetRect = CGRectNull;
    [self.selectionView.selectionRects enumerateObjectsUsingBlock:^(MPITextSelectionRect * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        targetRect = CGRectUnion(targetRect, obj.rect);
    }];
    if ([self.delegate respondsToSelector:@selector(label:showMenuWithMenuItems:targetRect:)]) {
        self.menuType = MPITextMenuTypeCustom;
        [self.delegate label:self showMenuWithMenuItems:menuItems targetRect:targetRect];
    } else {
        self.menuType = MPITextMenuTypeSystem;
        UIMenuController.sharedMenuController.menuItems = menuItems;
        if (@available(iOS 13, *)) {
            [UIMenuController.sharedMenuController showMenuFromView:self rect:targetRect];
        } else {
            [UIMenuController.sharedMenuController setTargetRect:targetRect inView:self];
            [UIMenuController.sharedMenuController setMenuVisible:YES animated:YES];
        }
    }
}

- (void)hideMenu {
    if (![self isMenuVisible]) {
        return;
    }
    self.menuType = MPITextMenuTypeNone;
    
    if ([self.delegate respondsToSelector:@selector(labelHideMenu:)]) {
        [self.delegate labelHideMenu:self];
    } else {
        if (@available(iOS 13, *)) {
            [UIMenuController.sharedMenuController hideMenu];
        } else {
            [UIMenuController.sharedMenuController setMenuVisible:NO animated:YES];
        }
    }
}

#pragma mark - MPITextInteractionManagerDelegate

- (void)interactionManager:(MPITextInteractionManager *)interactionManager didUpdateHighlightedAttributedText:(NSAttributedString *)highlightedAttributedText {
    [self invalidateAttachments];
    [self setNeedsUpdateContentsWithoutClearContents];
}

#pragma mark - MPITextAsyncLayerDelegate

- (MPITextAsyncLayerDisplayTask *)newAsyncDisplayTask {
    CGRect bounds = self.bounds;
    BOOL displaysAsync = self.displaysAsynchronously;
    BOOL fadeForAsync = displaysAsync && self.fadeOnAsynchronouslyDisplay;
    BOOL contentsUptodate = _state.contentsUpdated;
    MPITextDebugOption *debugOption = self.debugOption;
    BOOL attachmentsNeedsUpdate = _state.attachmentsNeedsUpdate;
    NSMutableArray *attachmentViews = self.attachmentViews;
    NSMutableArray *attachmentLayers = self.attachmentLayers;

    MPITextRenderer *renderer = [self currentRenderer];
    CGPoint point = [self convertPointFromTextKit:CGPointZero forBounds:bounds textSize:renderer.size];

    MPITextAsyncLayerDisplayTask *task = [MPITextAsyncLayerDisplayTask new];
    task.displaysAsynchronously = displaysAsync;
    
    task.willDisplay = ^(CALayer * _Nonnull layer) {
        MPILabel *label = (MPILabel *)layer.delegate;
        if (!label) {
            return;
        }
        
        [layer removeAnimationForKey:kAsyncFadeAnimationKey];
        
        if (attachmentsNeedsUpdate) {
            [label clearAttachmentViewsAndLayersWithAttachmetsInfo:renderer.attachmentsInfo];
        }
    };
    
    task.display = ^(CGContextRef  _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        if (isCancelled()) {
            return;
        }
        
        [renderer drawAtPoint:point debugOption:debugOption];
    };
    
    task.didDisplay = ^(CALayer * _Nonnull layer, BOOL finished) {
        MPILabel *label = (MPILabel *)layer.delegate;
        if (!label) {
            return;
        }
        
        if (!finished) {
            [label clearAttachmentViewsAndLayers];
            return;
        }
        
        if (attachmentsNeedsUpdate) {
            label->_state.attachmentsNeedsUpdate = NO;
            
            CGPoint point = [self convertPointFromTextKit:CGPointZero forBounds:bounds textSize:renderer.size];
            [renderer drawViewAndLayerAtPoint:point referenceTextView:label];
            
            for (MPITextAttachment *attachment in renderer.attachmentsInfo.attachments) {
                id content = attachment.content;
                if ([content isKindOfClass:UIView.class]) {
                    [attachmentViews addObject:content];
                } else if ([content isKindOfClass:CALayer.class]) {
                    [attachmentLayers addObject:content];
                }
            }
        }
        
        if (!contentsUptodate) {
            label->_state.contentsUpdated = YES;
        }
        
        if (fadeForAsync) {
            CATransition *transition = [CATransition animation];
            transition.duration = kAsyncFadeDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [layer addAnimation:transition forKey:kAsyncFadeAnimationKey];
        }
        
        [label updateSelectionView];
    };
    
    return task;
}

#pragma mark - MPITextDebugTarget

- (void)setDebugOption:(MPITextDebugOption *)debugOption {
    BOOL needsDraw = _debugOption.needsDrawDebug;
    _debugOption = debugOption.copy;
    if (_debugOption.needsDrawDebug != needsDraw) {
        [self setNeedsUpdateContents];
    }
}

#pragma mark - Custome Accessors

- (void)setTruncationAttributedToken:(NSAttributedString *)truncationAttributedToken {
    if (MPITextObjectIsEqual(_truncationAttributedToken, truncationAttributedToken)) {
        return;
    }
    
    _truncationAttributedToken = truncationAttributedToken;
    
    [self invalidateAttachments];
    [self invalidateTruncationAttributedText];
    
    [self setNeedsUpdateContents];
}

- (void)setAdditionalTruncationAttributedMessage:(NSAttributedString *)additionalTruncationAttributedMessage {
    if (MPITextObjectIsEqual(_additionalTruncationAttributedMessage, additionalTruncationAttributedMessage)) {
        return;
    }
    
    _additionalTruncationAttributedMessage = additionalTruncationAttributedMessage;
    
    [self invalidateAttachments];
    [self invalidateTruncationAttributedText];
    
    [self setNeedsUpdateContents];
}

- (NSAttributedString *)truncationAttributedText {
    if (!_truncationAttributedText) {
        _truncationAttributedText = MPITextTruncationAttributedTextWithTokenAndAdditionalMessage(self.attributedText,
                                                                                                 self.truncationAttributedToken,
                                                                                                 self.additionalTruncationAttributedMessage);
    }
    return _truncationAttributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (MPITextObjectIsEqual(_attributedText, attributedText)) {
        return;
    }
    
    _attributedText = attributedText.copy;
    
    [self invalidate];
}

- (void)setTextRenderer:(MPITextRenderer *)textRenderer {
    if (_textRenderer == textRenderer) {
        return;
    }
    
    _textRenderer = textRenderer;
    
    [self invalidate];
}

- (NSString *)text {
    return self.attributedText.string;
}

- (void)setText:(NSString *)text {
    if (text) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:[self attributesByProperties]];
        [attributedText mpi_setAlignment:self.textAlignment range:attributedText.mpi_rangeOfAll];
        self.attributedText = attributedText;
    } else {
        self.attributedText = nil;
    }
}

- (void)setFont:(UIFont *)font {
    if (MPITextObjectIsEqual(_font, font)) {
        return;
    }
    
    _font = font ? : [self defalutFont];
    
    [self updateAttributedTextAttribute:NSFontAttributeName
                                  value:_font];
}

- (void)setTextColor:(UIColor *)textColor {
    if (MPITextObjectIsEqual(_textColor, textColor)) {
        return;
    }
    
    _textColor = textColor ? : [self defalutTextColor];
    
    [self updateAttributedTextAttribute:NSForegroundColorAttributeName
                                  value:_textColor];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (MPITextObjectIsEqual(_shadowColor, shadowColor)) {
        return;
    }
    
    _shadowColor = shadowColor;
    
    [self updateAttributedTextAttribute:NSShadowAttributeName
                                  value:[self shadowByProperties]];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if (CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        return;
    }
    
    _shadowOffset = shadowOffset;
    
    [self updateAttributedTextAttribute:NSShadowAttributeName
                                  value:[self shadowByProperties]];
}

- (void)setShadowBlurRadius:(CGFloat)shadowBlurRadius {
    if (ABS(_shadowBlurRadius - shadowBlurRadius) < FLT_EPSILON) {
        return;
    }
    
    _shadowBlurRadius = shadowBlurRadius;
    
    [self updateAttributedTextAttribute:NSShadowAttributeName
                                  value:[self shadowByProperties]];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) {
        return;
    }
    
    _textAlignment = textAlignment;
    
    NSMutableAttributedString *attributedText = self.attributedText.mutableCopy;
    [attributedText mpi_setAlignment:_textAlignment range:attributedText.mpi_rangeOfAll];
    self.attributedText = attributedText;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) {
        return;
    }
    
    _numberOfLines = numberOfLines;
    
    [self invalidate];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode == lineBreakMode) {
        return;
    }
    
    _lineBreakMode = lineBreakMode;
    
    [self invalidate];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_textContainerInset, textContainerInset)) {
        return;
    }
    
    _textContainerInset = textContainerInset;
    
    [self invalidate];
}

- (void)setExclusionPaths:(NSArray<UIBezierPath *> *)exclusionPaths {
    if (MPITextObjectIsEqual(_exclusionPaths, exclusionPaths)) {
        return;
    }
    
    CGRect textRect = [self textRectForBounds:self.bounds textSize:[self currentRenderer].size];
    
    _exclusionPaths = exclusionPaths.copy;
    
    [_exclusionPaths enumerateObjectsUsingBlock:^(UIBezierPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj applyTransform:CGAffineTransformMakeTranslation(-textRect.origin.x, -textRect.origin.y)];
    }];
    
    [self invalidate];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (ABS(_preferredMaxLayoutWidth - preferredMaxLayoutWidth) < FLT_EPSILON) {
        return;
    }
    
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    
    [self invalidate];
}

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        [self setNeedsUpdateContents];
    }
}

- (void)setSelectable:(BOOL)selectable {
    if (_selectable != selectable) {
        _selectable = selectable;
        
        if (selectable) {
            if (!self.selectionView) {
                self.selectionView = [MPITextSelectionView new];
                [self addSubview:self.selectionView];
            }
        }
        
        [self updateSelectionView];
        
        self.interactionManager.grabberPanGestureRecognizer.enabled = selectable;
    }
}

- (void)setSelectedRange:(NSRange)selectedRange {
    if (!self.isSelectable) {
        return;
    }
    if (NSEqualRanges(_selectedRange, selectedRange)) {
        return;
    }
    
    _selectedRange = selectedRange;
    
    [self updateSelectionView];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.selectionView.tintColor = tintColor;
}

- (BOOL)isTruncated {
    return [[self currentRenderer] isTruncated];
}

- (NSRange)truncationRange {
    return [[self currentRenderer] truncationRange];
}

@end


