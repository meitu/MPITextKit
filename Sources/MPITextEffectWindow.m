//
//  MPITextEffectWindow.m
//  MPITextKit
//
//  Created by Tpphha on 2020/3/22.
//

#import "MPITextEffectWindow.h"
#import "MPITextGeometryHelpers.h"
#import "UIView+MPITextKit.h"

@interface MPITextEffectWindowViewController : UIViewController

@end

@implementation MPITextEffectWindowViewController

- (BOOL)shouldAutorotate {
    return NO;
}

@end

@implementation MPITextEffectWindow

+ (instancetype)sharedWindow {
    static MPITextEffectWindow *window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [self new];
        window.frame = (CGRect){.size = MPITextScreenSize()};
        window.userInteractionEnabled = NO;
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.hidden = NO;
        window.rootViewController = [MPITextEffectWindowViewController new];
        
        // for iOS 9:
        window.opaque = NO;
        window.backgroundColor = [UIColor clearColor];
        window.layer.backgroundColor = [UIColor clearColor].CGColor;
    });
    return window;
}

- (BOOL)_canAffectStatusBarAppearance {
    return NO;
}

- (void)showMagnifier:(MPITextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) {
        [self addSubview:mag];
    }
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self mpi_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
    trans = CGAffineTransformScale(trans, 0.3, 0.3);
    mag.transform = trans;
    mag.center = center;
    if (mag.type == MPITextMagnifierTypeRanged) {
        mag.alpha = 0;
    }
    NSTimeInterval time = mag.type == MPITextMagnifierTypeCaret ? 0.08 : 0.1;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (mag.type == MPITextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitsSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
        }
        mag.transform = CGAffineTransformMakeRotation(rotation);
        mag.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveMagnifier:(MPITextMagnifier *)mag {
    if (!mag) return;
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self mpi_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    if (mag.type == MPITextMagnifierTypeCaret) {
        CGPoint newCenter = CGPointMake(0, -mag.fitsSize.height / 2);
        newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
        newCenter.x += center.x;
        newCenter.y += center.y;
        mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
    } else {
        mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
    }
    mag.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)hideMagnifier:(MPITextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) return;
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self mpi_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    NSTimeInterval time = mag.type == MPITextMagnifierTypeCaret ? 0.20 : 0.15;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
        trans = CGAffineTransformScale(trans, 0.01, 0.01);
        mag.transform = trans;
        
        if (mag.type == MPITextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitsSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
            mag.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [mag removeFromSuperview];
            mag.transform = CGAffineTransformIdentity;
            mag.alpha = 1;
        }
    }];
}

#pragma mark - Private

- (CGPoint)_correctedCenter:(CGPoint)center forMagnifier:(MPITextMagnifier *)mag rotation:(CGFloat)rotation {
    CGFloat degree = MPITextRadiansToDegrees(rotation);
    
    degree /= 45.0;
    if (degree < 0) degree += (int)(-degree/8.0 + 1) * 8;
    if (degree > 8) degree -= (int)(degree/8.0) * 8;
    
    CGFloat caretExt = 10;
    if (degree <= 1 || degree >= 7) { //top
        if (mag.type == MPITextMagnifierTypeCaret) {
            if (center.y < caretExt)
                center.y = caretExt;
        } else if (mag.type == MPITextMagnifierTypeRanged) {
            if (center.y < mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (1 < degree && degree < 3) { // right
        if (mag.type == MPITextMagnifierTypeCaret) {
            if (center.x > self.bounds.size.width - caretExt)
                center.x = self.bounds.size.width - caretExt;
        } else if (mag.type == MPITextMagnifierTypeRanged) {
            if (center.x > self.bounds.size.width - mag.bounds.size.height)
                center.x = self.bounds.size.width - mag.bounds.size.height;
        }
    } else if (3 <= degree && degree <= 5) { // bottom
        if (mag.type == MPITextMagnifierTypeCaret) {
            if (center.y > self.bounds.size.height - caretExt)
                center.y = self.bounds.size.height - caretExt;
        } else if (mag.type == MPITextMagnifierTypeRanged) {
            if (center.y > mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (5 < degree && degree < 7) { // left
        if (mag.type == MPITextMagnifierTypeCaret) {
            if (center.x < caretExt)
                center.x = caretExt;
        } else if (mag.type == MPITextMagnifierTypeRanged) {
            if (center.x < mag.bounds.size.height)
                center.x = mag.bounds.size.height;
        }
    }
    
    return center;
}

/**
 Capture screen snapshot and set it to magnifier.
 @return Magnifier rotation radius.
 */
- (CGFloat)_updateMagnifier:(MPITextMagnifier *)mag {
    UIView *hostView = mag.hostView;
    UIWindow *hostWindow = [hostView isKindOfClass:[UIWindow class]] ? (id)hostView : hostView.window;
    if (!hostView || !hostWindow) return 0;
    CGPoint captureCenter = [self mpi_convertPoint:mag.hostCaptureCenter fromViewOrWindow:hostView];
    CGRect captureRect = {.size = mag.snapshotSize};
    captureRect.origin.x = captureCenter.x - captureRect.size.width / 2;
    captureRect.origin.y = captureCenter.y - captureRect.size.height / 2;
    
    CGAffineTransform trans = MPITextCGAffineTransformGetFromViews(hostView, self);
    CGFloat rotation = MPITextCGAffineTransformGetRotation(trans);
    
    if (mag.captureDisabled) {
        if (!mag.snapshot || mag.snapshot.size.width > 1) {
            static UIImage *placeholder;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect rect = mag.bounds;
                rect.origin = CGPointZero;
                UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [[UIColor colorWithWhite:1 alpha:0.8] set];
                CGContextFillRect(context, rect);
                placeholder = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            mag.captureFadeAnimation = YES;
            mag.snapshot = placeholder;
            mag.captureFadeAnimation = NO;
        }
        return rotation;
    }
    
    UIGraphicsBeginImageContextWithOptions(captureRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return rotation;
    
    CGPoint tp = CGPointMake(captureRect.size.width / 2, captureRect.size.height / 2);
    tp = CGPointApplyAffineTransform(tp, CGAffineTransformMakeRotation(rotation));
    CGContextRotateCTM(context, -rotation);
    CGContextTranslateCTM(context, tp.x - captureCenter.x, tp.y - captureCenter.y);
    CGContextSaveGState(context);
    CGContextConcatCTM(context, MPITextCGAffineTransformGetFromViews(hostWindow, self));
    [hostWindow.layer renderInContext:context];
//    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]; //slower when capture whole window
    CGContextRestoreGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (mag.snapshot.size.width == 1) {
        mag.captureFadeAnimation = YES;
    }
    mag.snapshot = image;
    mag.captureFadeAnimation = NO;
    return rotation;
}

@end
