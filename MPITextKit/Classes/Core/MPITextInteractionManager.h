//
//  MPITextInteractionManager.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextKitConst.h>
#else
#import "MPITextKitConst.h"
#endif

@class MPITextRenderer;
@class MPITextInteractiveGestureRecognizer;

@protocol MPITextInteractionManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol MPITextInteractable <NSObject>

@property (nullable, readonly) NSAttributedString *attributedText;

@property (nullable, nonatomic, strong) MPITextRenderer *textRenderer;

@property (nullable, readonly) NSAttributedString *truncationAttributedText;

@property (nonatomic, readonly, getter=isSelectable) BOOL selectable;

@property (nonatomic, readonly) NSRange selectedRange;

- (BOOL)shouldInteractLinkWithLinkRange:(NSRange)linkRange
                      forAttributedText:(NSAttributedString *)attributedText;

- (NSDictionary<NSString *, id> *)highlightedLinkTextAttributesWithLinkRange:(NSRange)linkRange
                                                          forAttributedText:(NSAttributedString *)attributedText;

- (void)tapLinkWithLinkRange:(NSRange)linkRange forAttributedText:(NSAttributedString *)attributedText;

- (void)longPressLinkWithLinkRange:(NSRange)linkRange forAttributedText:(NSAttributedString *)attributedText;

- (NSRange)linkRangeAtPoint:(CGPoint)point inTruncation:(nullable BOOL *)inTruncation;

- (BOOL)selectionAtPoint:(CGPoint)point;

- (MPITextSelectionGrabberType)grabberTypeAtPoint:(CGPoint)point;

- (CGRect)grabberRectForGrabberType:(MPITextSelectionGrabberType)grabberType;

- (NSUInteger)characterIndexForPoint:(CGPoint)point;

- (void)beginSelectionAtPoint:(CGPoint)point;

- (void)updateSelectionWithRange:(NSRange)range;

- (void)endSelection;

- (BOOL)isMenuVisible;

- (void)showMenu;

- (void)hideMenu;

@end

typedef UIView<MPITextInteractable> MPITextInteractableView;

@interface MPITextInteractionManager : NSObject 

/** The gesture recognizer used to detect interactions in this text view. */
@property (nonatomic, strong, readonly) MPITextInteractiveGestureRecognizer *interactiveGestureRecognizer;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *grabberPanGestureRecognizer;

@property (nonatomic, weak) id<MPITextInteractionManagerDelegate> delegate;

@property (nonatomic, readonly) BOOL hasActiveLink;
@property (nonatomic, readonly) NSRange activeLinkRange;
@property (nonatomic, readonly) BOOL activeInTruncation;
@property (nonatomic, readonly) NSAttributedString *attributedText;
@property (nullable, nonatomic, copy, readonly) NSAttributedString *highlightedAttributedText;

- (instancetype)initWithInteractableView:(MPITextInteractableView *)interactableView;

@end

@protocol MPITextInteractionManagerDelegate <NSObject>

- (void)interactionManager:(MPITextInteractionManager *)interactionManager didUpdateHighlightedAttributedText:(NSAttributedString *)highlightedAttributedText;

@end

NS_ASSUME_NONNULL_END



