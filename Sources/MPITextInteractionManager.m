//
//  MPITextInteractionManager.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextInteractionManager.h"
#import "MPITextInteractiveGestureRecognizer.h"
#import "MPITextEffectWindow.h"
#import "MPITextMagnifier.h"
#import "MPITextLink.h"
#import "MPITextRenderAttributes.h"
#import "MPITextRenderer.h"

#import "NSAttributedString+MPITextKit.h"

@interface MPITextInteractionManager () <UIGestureRecognizerDelegate> {
    struct {
        unsigned int showingRangedMagnifier : 1;
    } _state;
}

@property (nonatomic, weak) MPITextInteractableView *interactableView;

@property (nonatomic, strong) MPITextMagnifier *rangedMagnifier;

@property (nonatomic, assign) MPITextSelectionGrabberType trackingGrabberType;
@property (nonatomic, assign) NSUInteger pinnedGrabberIndex;

@property (nonatomic, assign) NSRange activeLinkRange;
@property (nonatomic, assign) BOOL activeInTruncation;

@property (nullable, nonatomic, copy) NSAttributedString *highlightedAttributedText;
@property (nullable, nonatomic, copy) NSAttributedString *snapshotAttributedText;

@end

@implementation MPITextInteractionManager
@synthesize grabberPanGestureRecognizer = _grabberPanGestureRecognizer;

- (instancetype)initWithInteractableView:(MPITextInteractableView *)interactableView {
    self = [super init];
    if (self) {
        _interactableView = interactableView;
        
        _interactiveGestureRecognizer = [[MPITextInteractiveGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveAction:)];
        _interactiveGestureRecognizer.delegate = self;
        [_interactableView addGestureRecognizer:_interactiveGestureRecognizer];
        
        _activeLinkRange = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

#pragma mark - Gesture Recognition

- (void)interactiveAction:(MPITextInteractiveGestureRecognizer *)recognizer {
    MPITextInteractableView *interactableView = self.interactableView;
    CGPoint location = [recognizer locationInView:interactableView];
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        [self showActiveLinkIfNeeded];
    } else if (state == UIGestureRecognizerStateEnded) {
        BOOL inSelection = interactableView.isSelectable ? [interactableView selectionAtPoint:location] : NO;
        if (recognizer.result == MPITextInteractiveGestureRecognizerResultTap) {
            [self tapLinkIfNeeded];
            if (inSelection) {
                if (self.hasActiveLink) {
                    [self hideMenu];
                } else {
                    [self toggleMenu];
                }
            } else {
                [self endSelection];
            }
        } else if (recognizer.result == MPITextInteractiveGestureRecognizerResultLongPress) {
            if (interactableView.isSelectable) {
                if (inSelection) {
                    [self longPressLinkIfNeeded];
                    if (self.hasActiveLink) {
                        [self hideMenu];
                    }
                } else {
                    [self beginSelectionAtPoint:location];
                }
            } else {
                [self longPressLinkIfNeeded];
            }
        }
    }
    
    if (state == UIGestureRecognizerStateEnded ||
        state == UIGestureRecognizerStateCancelled ||
        state == UIGestureRecognizerStateFailed) {
        [self hideActiveLinkIfNeeded];
    }
}

- (void)grabberPanAction:(UIPanGestureRecognizer *)recognizer {
    MPITextInteractableView *interactableView = self.interactableView;
    CGPoint location = [recognizer locationInView:interactableView];
    UIGestureRecognizerState state = recognizer.state;
    MPITextSelectionGrabberType grabberType = self.trackingGrabberType;
    if (state == UIGestureRecognizerStateBegan) {
        [self hideMenu];
        
        if (grabberType == MPITextSelectionGrabberTypeStart) {
            self.pinnedGrabberIndex = NSMaxRange(interactableView.selectedRange) - 1;
        } else if (grabberType == MPITextSelectionGrabberTypeEnd) {
            self.pinnedGrabberIndex = interactableView.selectedRange.location;
        }
    }
    
    NSUInteger characterIndex = [interactableView characterIndexForPoint:location];
    NSUInteger pinnedGrabberIndex = self.pinnedGrabberIndex;
    NSRange selectedRange = interactableView.selectedRange;
    BOOL isStartGrabber = grabberType == MPITextSelectionGrabberTypeStart;
    if (characterIndex != NSNotFound) {
        if (characterIndex < pinnedGrabberIndex) {
            selectedRange = NSMakeRange(characterIndex,
                                        pinnedGrabberIndex - characterIndex + (isStartGrabber ? 1 : 0));
        } else if (characterIndex > pinnedGrabberIndex) {
            NSUInteger location = isStartGrabber ? pinnedGrabberIndex + 1 : pinnedGrabberIndex;
            selectedRange = NSMakeRange(location,
                                        characterIndex - location + 1);
        } else {
            selectedRange = NSMakeRange(pinnedGrabberIndex, 1);
        }
    }
    
    [interactableView updateSelectionWithRange:selectedRange];
    
    if (state == UIGestureRecognizerStateBegan) {
        [self showRangedMagnifierAtCharacterIndex:characterIndex];
    } else if (state == UIGestureRecognizerStateChanged) {
        [self moveRangedMagnifierAtCharacterIndex:characterIndex];
    }
    
    if (state == UIGestureRecognizerStateEnded ||
        state == UIGestureRecognizerStateCancelled ||
        state == UIGestureRecognizerStateFailed) {
        [self hideRangedMagnifier];
        [self showMenu];
        
        self.trackingGrabberType = MPITextSelectionGrabberTypeNone;
        self.pinnedGrabberIndex = NSNotFound;
    }
}

#pragma mark - Private (Action)

- (void)tapLinkIfNeeded {
    if (!self.hasActiveLink) {
        return;
    }
    [self.interactableView tapLinkWithLinkRange:self.activeLinkRange forAttributedText:self.snapshotAttributedText];
}

- (void)longPressLinkIfNeeded {
    if (!self.hasActiveLink) {
        return;
    }
    [self.interactableView longPressLinkWithLinkRange:self.activeLinkRange forAttributedText:self.snapshotAttributedText];
}

- (void)beginSelectionAtPoint:(CGPoint)point {
    [self.interactableView beginSelectionAtPoint:point];
}

- (void)endSelection {
    [self.interactableView endSelection];
}

#pragma mark - Private (Utils)

- (NSRange)linkRangeAtPoint:(CGPoint)point inTruncation:(BOOL *)inTruncation {
    return [self.interactableView linkRangeAtPoint:point inTruncation:inTruncation];
}

- (NSRange)linkRangeAtPoint:(CGPoint)point {
    return [self linkRangeAtPoint:point inTruncation:NULL];
}

- (BOOL)containsLinkAtPoint:(CGPoint)point {
    return [self linkRangeAtPoint:point].location != NSNotFound;
}

- (void)notifyDidUpdateHighlightedAttributedText {
    [self.delegate interactionManager:self didUpdateHighlightedAttributedText:self.highlightedAttributedText];
}

#pragma mark - Private (Link)

- (void)showActiveLinkIfNeeded {
    if (!self.hasActiveLink) {
        return;
    }
    MPITextInteractableView *interactableView = self.interactableView;
    
    NSMutableAttributedString *highlightedLinkAttributedText = [[self.snapshotAttributedText attributedSubstringFromRange:self.activeLinkRange] mutableCopy];
    
    NSDictionary<NSString *, id> *textAttributes = [interactableView highlightedLinkTextAttributesWithLinkRange:self.activeLinkRange
                                                                                              forAttributedText:self.snapshotAttributedText];
    if (textAttributes) {
        [highlightedLinkAttributedText addAttributes:textAttributes range:highlightedLinkAttributedText.mpi_rangeOfAll];
    }
    [highlightedLinkAttributedText addAttribute:MPITextHighlightedAttributeName value:@(YES) range:highlightedLinkAttributedText.mpi_rangeOfAll];
    
    NSMutableAttributedString *highlightedAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.snapshotAttributedText];
    [highlightedAttributedText replaceCharactersInRange:self.activeLinkRange withAttributedString:highlightedLinkAttributedText];
    
    self.highlightedAttributedText = highlightedAttributedText;
    
    [self notifyDidUpdateHighlightedAttributedText];
}

- (void)hideActiveLinkIfNeeded {
    if (!self.hasActiveLink) {
        return;
    }
    
    [self clearActiveLink];
    
    [self notifyDidUpdateHighlightedAttributedText];
}

- (NSAttributedString *)captureAttributedTextWithActiveInTruncation:(BOOL)activeInTruncation {
    MPITextInteractableView *interactableView = self.interactableView;
    if (interactableView.textRenderer) {
        MPITextRenderAttributes *renderAttributes = interactableView.textRenderer.renderAttributes;
        return activeInTruncation ? renderAttributes.truncationAttributedText : renderAttributes.attributedText;
    } else {
        return activeInTruncation ? interactableView.truncationAttributedText : interactableView.attributedText;
    }
}

- (void)clearActiveLink {
    self.activeLinkRange = NSMakeRange(NSNotFound, 0);
    self.activeInTruncation = NO;
    self.highlightedAttributedText = nil;
    self.snapshotAttributedText = nil;
}

#pragma mark - Private (Menu)

- (BOOL)isMenuVisible {
    return [self.interactableView isMenuVisible];
}

- (void)showMenu {
    [self.interactableView showMenu];
}

- (void)hideMenu {
    [self.interactableView hideMenu];
}

- (void)toggleMenu {
    if ([self isMenuVisible]) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

#pragma mark - Private (Magnifier)

- (void)updateRangedMagnifierSettingWithCharacterIndex:(NSUInteger)characterIndex {
    MPITextInteractableView *interactableView = self.interactableView;
    
    MPITextSelectionGrabberType grabberType = characterIndex < self.pinnedGrabberIndex ? MPITextSelectionGrabberTypeStart : MPITextSelectionGrabberTypeEnd;
    CGRect grabberRect = [interactableView grabberRectForGrabberType:grabberType];
    
    CGPoint grabberCenter = CGPointMake(CGRectGetMidX(grabberRect), CGRectGetMidY(grabberRect));
    self.rangedMagnifier.hostCaptureCenter = grabberCenter;
    self.rangedMagnifier.hostPopoverCenter = CGPointMake(grabberCenter.x, CGRectGetMinY(grabberRect));
}

- (void)showRangedMagnifierAtCharacterIndex:(NSUInteger)characterIndex {
    _state.showingRangedMagnifier = YES;
    
    [self updateRangedMagnifierSettingWithCharacterIndex:characterIndex];
    
    [[MPITextEffectWindow sharedWindow] showMagnifier:self.rangedMagnifier];
}

- (void)moveRangedMagnifierAtCharacterIndex:(NSUInteger)characterIndex {
    [self updateRangedMagnifierSettingWithCharacterIndex:characterIndex];
    [[MPITextEffectWindow sharedWindow] moveMagnifier:self.rangedMagnifier];
}

- (void)hideRangedMagnifier {
    if (!_state.showingRangedMagnifier) {
        return;
    }
    _state.showingRangedMagnifier = NO;
    
    [[MPITextEffectWindow sharedWindow] hideMagnifier:self.rangedMagnifier];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    if (self.interactableView.selectable) {
        if (gestureRecognizer == self.grabberPanGestureRecognizer &&
            [otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    MPITextInteractableView *interactableView = self.interactableView;
    CGPoint location = [gestureRecognizer locationInView:interactableView];
    if (gestureRecognizer == self.interactiveGestureRecognizer) {
        NSAttributedString *snapshotAttributedTextBefore = [self captureAttributedTextWithActiveInTruncation:NO];
        NSAttributedString *snapshotTruncationAttributedTextBefore = [self captureAttributedTextWithActiveInTruncation:YES];
        BOOL activeInTruncation = NO;
        self.activeLinkRange = [self linkRangeAtPoint:location inTruncation:&activeInTruncation];
        self.activeInTruncation = activeInTruncation;
        NSAttributedString *snapshotAttributedTextEnd = [self captureAttributedTextWithActiveInTruncation:NO];
        NSAttributedString *snapshotTruncationAttributedTextEnd = [self captureAttributedTextWithActiveInTruncation:YES];
        if (snapshotAttributedTextBefore != snapshotAttributedTextEnd ||
            snapshotTruncationAttributedTextBefore != snapshotTruncationAttributedTextEnd) { // The attributedText was changed
            [self clearActiveLink];
        }
        
        if (self.activeLinkRange.location != NSNotFound) {
            if (self.activeInTruncation) {
                self.snapshotAttributedText = snapshotTruncationAttributedTextEnd;
            } else {
                self.snapshotAttributedText = snapshotAttributedTextEnd;
            }
            BOOL shouldInteractLink = [interactableView shouldInteractLinkWithLinkRange:self.activeLinkRange
                                                                      forAttributedText:self.snapshotAttributedText];
            if (!shouldInteractLink) {
                [self clearActiveLink];
            }
        }
        
        return interactableView.isSelectable ? YES : [self hasActiveLink];
    } else if (interactableView.isSelectable && gestureRecognizer == self.grabberPanGestureRecognizer) {
        self.trackingGrabberType = [interactableView grabberTypeAtPoint:location];
        return self.trackingGrabberType != MPITextSelectionGrabberTypeNone;
    }
    return NO;
}

#pragma mark - Custom Accessors

- (BOOL)hasActiveLink {
    return
    self.activeLinkRange.location != NSNotFound &&
    self.activeLinkRange.length > 0;
}

- (UIPanGestureRecognizer *)grabberPanGestureRecognizer {
    if (!_grabberPanGestureRecognizer) {
        _grabberPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(grabberPanAction:)];
        _grabberPanGestureRecognizer.delegate = self;
        [self.interactableView addGestureRecognizer:_grabberPanGestureRecognizer];
    }
    return _grabberPanGestureRecognizer;
}

- (MPITextMagnifier *)rangedMagnifier {
    if (!_rangedMagnifier) {
        _rangedMagnifier = [MPITextMagnifier magnifierWithType:MPITextMagnifierTypeRanged];
        _rangedMagnifier.hostView = self.interactableView;
    }
    return _rangedMagnifier;
}

@end

