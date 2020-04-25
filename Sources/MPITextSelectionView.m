//
//  MPITextSelectionView.m
//  MPITextKit
//
//  Created by Tpphha on 2020/3/8.
//

#import "MPITextSelectionView.h"
#import "MPITextGeometryHelpers.h"

#define kGrabberTouchHitTestExtend 14.0
#define kKnobTouchHitTestExtend 7.0
#define kSelectionAlpha 0.2

@implementation MPITextSelectionGrabberKnob

@end

@implementation MPITextSelectionGrabber

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _knobDiameter = 10;
        _knob = [[MPITextSelectionGrabberKnob alloc] initWithFrame:CGRectMake(0, 0, _knobDiameter, _knobDiameter)];
        [self addSubview:_knob];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateKnob];
}

- (CGRect)touchRect {
    CGRect rect = CGRectInset(self.frame, -kGrabberTouchHitTestExtend, -kGrabberTouchHitTestExtend);
    UIEdgeInsets insets = {0};
    if (self.knobDirection == UITextLayoutDirectionUp) {
        insets.top = -kKnobTouchHitTestExtend;
    } else if (self.knobDirection == UITextLayoutDirectionRight) {
        insets.right = -kKnobTouchHitTestExtend;
    } else if (self.knobDirection == UITextLayoutDirectionDown) {
        insets.bottom = -kKnobTouchHitTestExtend;
    } else if (self.knobDirection == UITextLayoutDirectionLeft) {
        insets.left = -kKnobTouchHitTestExtend;
    }
    rect = UIEdgeInsetsInsetRect(rect, insets);
    return rect;
}

- (void)updateKnob {
    BOOL knobHidden = NO;
    CGRect frame = self.knob.frame;
    frame.size = CGSizeMake(self.knobDiameter, self.knobDiameter);
    CGFloat ofs = 0.5;
    UITextLayoutDirection knobDirection = self.knobDirection;
    if (knobDirection == UITextLayoutDirectionUp) {
        frame.origin.y = -frame.size.height + ofs;
        frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    } else if (knobDirection == UITextLayoutDirectionRight) {
        frame.origin.x = self.bounds.size.width - ofs;
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    } else if (knobDirection == UITextLayoutDirectionDown) {
        frame.origin.y = self.bounds.size.height - ofs;
        frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    } else if (knobDirection == UITextLayoutDirectionLeft) {
        frame.origin.x = -frame.size.width + ofs;
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    } else {
        knobHidden = YES;
    }
    self.knob.frame = frame;
    self.knob.hidden = knobHidden;
    self.knob.layer.cornerRadius = self.knobDiameter * 0.5;
}

- (void)setKnobDirection:(UITextLayoutDirection)dotDirection {
    _knobDirection = dotDirection;
    [self updateKnob];
}

- (void)setKnobDiameter:(CGFloat)knobDiameter {
    CGRect knobFrame = self.knob.frame;
    knobFrame.size = CGSizeMake(knobDiameter, knobDiameter);
    [self updateKnob];
}

- (void)setGrabberColor:(UIColor *)grabberColor {
    _grabberColor = grabberColor;
    self.backgroundColor = grabberColor;
    self.knob.backgroundColor = grabberColor;
}

@end

@interface MPITextSelectionView ()

@property (nonatomic, strong) MPITextSelectionGrabber *startGrabber;
@property (nonatomic, strong) MPITextSelectionGrabber *endGrabber;
@property (nonatomic, strong) NSMutableArray<UIView *> *selectionViews;

@property(nonatomic, strong) UIColor *selectionColor;
@property(nonatomic, strong) UIColor *grabberColor;

@end

@implementation MPITextSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        
        UIColor *grabberColor = [UIColor colorWithRed:69/255.0 green:111/255.0 blue:238/255.0 alpha:1];
        
        _selectionColor = [grabberColor colorWithAlphaComponent:kSelectionAlpha];
        
        _selectionViews = [NSMutableArray array];
        _startGrabber = [MPITextSelectionGrabber new];
        _startGrabber.knobDirection = UITextLayoutDirectionUp;
        _startGrabber.hidden = YES;
        _startGrabber.grabberColor = grabberColor;
        _endGrabber = [MPITextSelectionGrabber new];
        _endGrabber.knobDirection = UITextLayoutDirectionDown;
        _endGrabber.hidden = YES;
        _endGrabber.grabberColor = grabberColor;
        _grabberWidth = 2.0;

        [self addSubview:_startGrabber];
        [self addSubview:_endGrabber];
    }
    return self;
}

- (BOOL)isGrabberContainsPoint:(CGPoint)point {
    return [self isStartGrabberContainsPoint:point] || [self isEndGrabberContainsPoint:point];
}

- (BOOL)isStartGrabberContainsPoint:(CGPoint)point {
    if (self.startGrabber.hidden) return NO;
    CGRect startRect = [self.startGrabber touchRect];
    CGRect endRect = [self.endGrabber touchRect];
    if (CGRectIntersectsRect(startRect, endRect)) {
        CGFloat distStart = MPITextCGPointGetDistanceToPoint(point, MPITextCGRectGetCenter(startRect));
        CGFloat distEnd = MPITextCGPointGetDistanceToPoint(point, MPITextCGRectGetCenter(endRect));
        if (distEnd <= distStart) return NO;
    }
    return CGRectContainsPoint(startRect, point);
}

- (BOOL)isEndGrabberContainsPoint:(CGPoint)point {
    if (self.endGrabber.hidden) return NO;
    CGRect startRect = [self.startGrabber touchRect];
    CGRect endRect = [self.endGrabber touchRect];
    if (CGRectIntersectsRect(startRect, endRect)) {
        CGFloat distStart = MPITextCGPointGetDistanceToPoint(point, MPITextCGRectGetCenter(startRect));
        CGFloat distEnd = MPITextCGPointGetDistanceToPoint(point, MPITextCGRectGetCenter(endRect));
        if (distEnd > distStart) return NO;
    }
    return CGRectContainsPoint(endRect, point);
}

- (BOOL)isSelectionRectsContainsPoint:(CGPoint)point {
    if (self.selectionRects.count == 0) return NO;
    for (MPITextSelectionRect *rect in self.selectionRects) {
        if (CGRectContainsPoint(rect.rect, point)) return YES;
    }
    return NO;
}

- (void)updateSelectionRects:(NSArray<MPITextSelectionRect *> *)selectionRects
          startGrabberHeight:(CGFloat)startGrabberHeight
            endGrabberHeight:(CGFloat)endGrabberHeight {
    _selectionRects = selectionRects.copy;
    
    [self.selectionViews enumerateObjectsUsingBlock: ^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.selectionViews removeAllObjects];
    self.startGrabber.hidden = YES;
    self.endGrabber.hidden = YES;
     
    [selectionRects enumerateObjectsUsingBlock: ^(MPITextSelectionRect *obj, NSUInteger idx, BOOL *stop) {
        CGRect rect = obj.rect;
        rect = CGRectStandardize(rect);
        rect = MPITextCGRectPixelRound(rect);
        if (obj.containsStart || obj.containsEnd) {
            if (obj.containsStart) {
                self.startGrabber.hidden = NO;
                self.startGrabber.frame = [self grabberRectFromSelectionRect:rect
                                                                     isStart:YES
                                                          startGrabberHeight:startGrabberHeight
                                                            endGrabberHeight:endGrabberHeight];
            }
            if (obj.containsEnd) {
                self.endGrabber.hidden = NO;
                self.endGrabber.frame = [self grabberRectFromSelectionRect:rect
                                                                   isStart:NO
                                                        startGrabberHeight:startGrabberHeight
                                                          endGrabberHeight:endGrabberHeight];
            }
        }
        if (rect.size.width > 0 && rect.size.height > 0) {
            UIView *selectionView = [[UIView alloc] initWithFrame:rect];
            selectionView.backgroundColor = self.selectionColor;
            [self insertSubview:selectionView atIndex:0];
            [self.selectionViews addObject:selectionView];
        }
    }];
}

#pragma mark - Private

- (CGRect)grabberRectFromSelectionRect:(CGRect)selectionRect
                               isStart:(BOOL)isStart
                    startGrabberHeight:(CGFloat)startGrabberHeight
                      endGrabberHeight:(CGFloat)endGrabberHeight {
    selectionRect = CGRectStandardize(selectionRect);
    CGRect grabberRect = CGRectStandardize(selectionRect);
    CGFloat grabberWidth = self.grabberWidth;
    if (self.isVerticalForm) {
        if (isStart) {
            grabberRect.origin.y = CGRectGetMinY(selectionRect) - grabberWidth;
            grabberRect.size.width = startGrabberHeight;
        } else {
            grabberRect.origin.y = CGRectGetMaxY(selectionRect);
            grabberRect.size.width = endGrabberHeight;
        }
        grabberRect.size.height = grabberWidth;
        if (CGRectGetMinY(grabberRect) < 0) {
            grabberRect.origin.y = 0;
        } else if (CGRectGetMaxY(grabberRect) > CGRectGetHeight(self.bounds)) {
            grabberRect.origin.y = CGRectGetHeight(self.bounds) - grabberWidth;
        }
    } else {
        if (isStart) {
            grabberRect.origin.x = CGRectGetMinX(selectionRect) - grabberWidth;
            grabberRect.origin.y = CGRectGetMinY(selectionRect);
            grabberRect.size.height = startGrabberHeight;
        } else {
            grabberRect.origin.x = CGRectGetMaxX(selectionRect);
            grabberRect.origin.y = CGRectGetMaxY(selectionRect) - endGrabberHeight;
            grabberRect.size.height = endGrabberHeight;
        }
        grabberRect.size.width = grabberWidth;
        if (grabberRect.origin.x < 0) {
            grabberRect.origin.x = 0;
        } else if (CGRectGetMaxX(grabberRect) > CGRectGetWidth(self.bounds)) {
            grabberRect.origin.x = CGRectGetWidth(self.bounds) - grabberWidth;
        }
    }
    grabberRect = MPITextCGRectPixelRound(grabberRect);
    if (isnan(grabberRect.origin.x) || isinf(grabberRect.origin.x)) grabberRect.origin.x = 0;
    if (isnan(grabberRect.origin.y) || isinf(grabberRect.origin.y)) grabberRect.origin.y = 0;
    if (isnan(grabberRect.size.width) || isinf(grabberRect.size.width)) grabberRect.size.width = 0;
    if (isnan(grabberRect.size.height) || isinf(grabberRect.size.height)) grabberRect.size.height = 0;
    return grabberRect;
}

#pragma mark - Custom Accessors

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.grabberColor = tintColor;
    self.selectionColor = [tintColor colorWithAlphaComponent:kSelectionAlpha];
}

- (void)setGrabberColor:(UIColor *)grabberColor {
    self.startGrabber.grabberColor = grabberColor;
    self.endGrabber.grabberColor = grabberColor;
}

- (void)setSelectionColor:(UIColor *)selectionColor {
    if (_selectionColor != selectionColor) {
        _selectionColor = selectionColor;
        [self.selectionViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = selectionColor;
        }];
    }
}

- (void)setVerticalForm:(BOOL)verticalForm {
    if (_verticalForm != verticalForm) {
        _verticalForm = verticalForm;
        self.startGrabber.knobDirection = verticalForm ? UITextLayoutDirectionRight : UITextLayoutDirectionUp;
        self.endGrabber.knobDirection = verticalForm ? UITextLayoutDirectionLeft : UITextLayoutDirectionDown;
    }
}

- (void)setGrabberWidth:(CGFloat)grabberWidth {
    _grabberWidth = grabberWidth;
    
    CGRect startGrabberFrame = self.startGrabber.frame;
    CGRect endGrabberFrame = self.endGrabber.frame;
    if (self.isVerticalForm) {
        startGrabberFrame.origin.y = CGRectGetMaxY(startGrabberFrame) - grabberWidth;
        startGrabberFrame.size.height = grabberWidth;
        endGrabberFrame.size.height = grabberWidth;
    } else {
        startGrabberFrame.origin.x = CGRectGetMaxX(startGrabberFrame) - grabberWidth;
        startGrabberFrame.size.width = grabberWidth;
        endGrabberFrame.size.width = grabberWidth;
    }
    self.startGrabber.frame = startGrabberFrame;
    self.endGrabber.frame = endGrabberFrame;
}

@end
