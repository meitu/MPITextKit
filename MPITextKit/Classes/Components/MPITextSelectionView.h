//
//  MPITextSelectionView.h
//  MPITextKit
//
//  Created by Tpphha on 2020/3/8.
//

#import <UIKit/UIKit.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextInput.h>
#else
#import "MPITextInput.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MPITextSelectionGrabberKnob : UIView

@end

@interface MPITextSelectionGrabber : UIView

@property(nonatomic, strong) MPITextSelectionGrabberKnob *knob;

@property(nonatomic, assign) UITextLayoutDirection knobDirection;

@property(nonatomic, assign) CGFloat knobDiameter;

@property(nonatomic, strong) UIColor *grabberColor;

@end

@interface MPITextSelectionView : UIView

/// weather the text view is vertical form
@property(nonatomic, getter = isVerticalForm) BOOL verticalForm;

@property(nonatomic, readonly) MPITextSelectionGrabber *startGrabber;
@property(nonatomic, readonly) MPITextSelectionGrabber *endGrabber;

/// default is 2.0
@property(nonatomic, assign) CGFloat grabberWidth;

@property (nullable, nonatomic, copy, readonly) NSArray<MPITextSelectionRect *> *selectionRects;

- (BOOL)isGrabberContainsPoint:(CGPoint)point;
- (BOOL)isStartGrabberContainsPoint:(CGPoint)point;
- (BOOL)isEndGrabberContainsPoint:(CGPoint)point;
- (BOOL)isSelectionRectsContainsPoint:(CGPoint)point;

- (void)updateSelectionRects:(NSArray<MPITextSelectionRect *> *)selectionRects
          startGrabberHeight:(CGFloat)startGrabberHeight
            endGrabberHeight:(CGFloat)endGrabberHeight;

@end

NS_ASSUME_NONNULL_END
