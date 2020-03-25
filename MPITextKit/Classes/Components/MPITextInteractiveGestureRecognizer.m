//
//  MPIInteractionGestureRecognizer.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextInteractiveGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface MPITextInteractiveGestureRecognizer ()

@property (nonatomic) MPITextInteractiveGestureRecognizerResult result;
@property (nonatomic) CGPoint initialPoint;
@property (nonatomic) NSTimer *timer;

@end

// disable long tap

@implementation MPITextInteractiveGestureRecognizer

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // Same defaults as UILongPressGestureRecognizer
    _minimumPressDuration = 0.5;
    _allowableMovement = 10;
    
    _result = MPITextInteractiveGestureRecognizerResultUnknown;
    _initialPoint = CGPointZero;
}

- (void)reset {
    [super reset];
    
    self.result = MPITextInteractiveGestureRecognizerResultUnknown;
    self.initialPoint = CGPointZero;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)longPressed:(NSTimer *)timer {
    [timer invalidate];
    
    self.result = MPITextInteractiveGestureRecognizerResultLongPress;
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    NSAssert(self.result == MPITextInteractiveGestureRecognizerResultUnknown, @"Invalid result state");
    
    UITouch *touch = touches.anyObject;
    self.initialPoint = [touch locationInView:self.view];
    self.state = UIGestureRecognizerStateBegan;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.minimumPressDuration target:self selector:@selector(longPressed:) userInfo:nil repeats:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if (![self touchIsCloseToInitialPoint:touches.anyObject]) {
        self.result = MPITextInteractiveGestureRecognizerResultFailed;
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if ([self touchIsCloseToInitialPoint:touches.anyObject]) {
        self.result = MPITextInteractiveGestureRecognizerResultTap;
        self.state = UIGestureRecognizerStateRecognized;
    } else {
        self.result = MPITextInteractiveGestureRecognizerResultFailed;
        self.state = UIGestureRecognizerStateRecognized;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.result = MPITextInteractiveGestureRecognizerResultCancelled;
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)touchIsCloseToInitialPoint:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    CGFloat xDistance = (self.initialPoint.x - point.x);
    CGFloat yDistance = (self.initialPoint.y - point.y);
    CGFloat squaredDistance = (xDistance * xDistance) + (yDistance * yDistance);
    
    BOOL isClose = (squaredDistance <= (self.allowableMovement * self.allowableMovement));
    return isClose;
}

@end

