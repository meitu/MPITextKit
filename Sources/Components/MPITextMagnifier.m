//
//  MPITextMagnifier.m
//  MPITextKit
//
//  Created by Tpphha on 2020/3/8.
//

#import "MPITextMagnifier.h"
#import "MPITextGeometryHelpers.h"

#define kCaptureDisableFadeTime 0.1


@interface MPITextCaretMagnifier : MPITextMagnifier {
    UIImageView *_contentView;
    UIImageView *_coverView;
}
@end

@implementation MPITextCaretMagnifier

#define kMultiple 1.2
#define kDiameter 113.0
#define kPadding 7.0
#define kSize CGSizeMake(kDiameter + kPadding * 2, kDiameter + kPadding * 2)

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _contentView = [UIImageView new];
    _contentView.frame = CGRectMake(kPadding, kPadding, kDiameter, kDiameter);
    _contentView.layer.cornerRadius = kDiameter / 2;
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    
    _coverView = [UIImageView new];
    _coverView.frame = (CGRect){.origin = CGPointZero, .size = kSize};
    _coverView.image = [self.class coverImage];
    [self addSubview:_coverView];
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.frame = (CGRect){.size = [self sizeThatFits:CGSizeZero]};
    }
    return self;
}

- (MPITextMagnifierType)type {
    return MPITextMagnifierTypeCaret;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)setSnapshot:(UIImage *)snapshot {
    if (self.captureFadeAnimation) {
        [_contentView.layer removeAnimationForKey:@"contents"];
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.duration = kCaptureDisableFadeTime;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [_contentView.layer addAnimation:animation forKey:@"contents"];
    }
    _contentView.image = snapshot;
}

- (UIImage *)snapshot {
    return _contentView.image;
}

- (CGSize)snapshotSize {
    CGFloat length = floor(kDiameter / 1.2);
    return CGSizeMake(length, length);
}

- (CGSize)fitsSize {
    return [self sizeThatFits:CGSizeZero];
}

+ (UIImage *)coverImage {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = kSize;
        CGRect rect = (CGRect) {.size = size, .origin = CGPointZero};
        rect = CGRectInset(rect, kPadding, kPadding);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGPathRef boxPath = CGPathCreateWithRect(CGRectMake(0, 0, size.width, size.height), NULL);
        CGPathRef fillPath = CGPathCreateWithEllipseInRect(rect, NULL);
        CGPathRef strokePath = CGPathCreateWithEllipseInRect(MPITextCGRectPixelHalf(rect), NULL);
        
        // inner shadow
        CGContextSaveGState(context); {
            CGFloat blurRadius = 25;
            CGSize offset = CGSizeMake(0, 15);
            CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.16].CGColor;
            CGColorRef opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
            CGContextAddPath(context, fillPath);
            CGContextClip(context);
            CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
            CGContextBeginTransparencyLayer(context, NULL); {
                CGContextSetShadowWithColor(context, offset, blurRadius, opaqueShadowColor);
                CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                CGContextSetFillColorWithColor(context, opaqueShadowColor);
                CGContextAddPath(context, fillPath);
                CGContextFillPath(context);
            } CGContextEndTransparencyLayer(context);
            CGColorRelease(opaqueShadowColor);
        } CGContextRestoreGState(context);
        
        // outer shadow
        CGContextSaveGState(context); {
            CGContextAddPath(context, boxPath);
            CGContextAddPath(context, fillPath);
            CGContextEOClip(context);
            CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.32].CGColor;
            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5), 3, shadowColor);
            CGContextBeginTransparencyLayer(context, NULL); {
                CGContextAddPath(context, fillPath);
                [[UIColor colorWithWhite:0.7 alpha:1.000] setFill];
                CGContextFillPath(context);
            } CGContextEndTransparencyLayer(context);
        } CGContextRestoreGState(context);
        
        // stroke
        CGContextSaveGState(context); {
            CGContextAddPath(context, strokePath);
            [[UIColor colorWithWhite:0.6 alpha:1] setStroke];
            CGContextSetLineWidth(context, MPITextCGFloatFromPixel(1));
            CGContextStrokePath(context);
        } CGContextRestoreGState(context);
        
        CFRelease(boxPath);
        CFRelease(fillPath);
        CFRelease(strokePath);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}


#undef kMultiple
#undef kDiameter
#undef kPadding
#undef kSize

@end



@interface MPITextRangedMagnifier : MPITextMagnifier {
    UIImageView *_contentView;
    UIImageView *_coverView;
}
@end


@implementation MPITextRangedMagnifier
#define kMultiple 1.2
#define kSize CGSizeMake(141, 60)
#define kPadding MPITextCGFloatPixelHalf(6.0)
#define kRadius 6.0
#define kHeight 32.0
#define kArrow 14.0

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [UIImageView new];
        _contentView.frame = CGRectMake(kPadding, kPadding, kSize.width - 2 * kPadding, kHeight);
        _contentView.layer.cornerRadius = kRadius;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _coverView = [UIImageView new];
        _coverView.frame = (CGRect){.origin = CGPointZero, .size = kSize};
        _coverView.image = [self.class coverImage];
        [self addSubview:_coverView];
        
        self.layer.anchorPoint = CGPointMake(0.5, 1.2);
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.frame = (CGRect){.size = [self sizeThatFits:CGSizeZero]};
    }
    return self;
}

- (MPITextMagnifierType)type {
    return MPITextMagnifierTypeRanged;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)setSnapshot:(UIImage *)snapshot {
    if (self.captureFadeAnimation) {
        [_contentView.layer removeAnimationForKey:@"contents"];
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.duration = kCaptureDisableFadeTime;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [_contentView.layer addAnimation:animation forKey:@"contents"];
    }
    _contentView.image = snapshot;
}

- (UIImage *)snapshot {
    return _contentView.image;
}

- (CGSize)snapshotSize {
    CGSize size;
    size.width = floor((kSize.width - 2 * kPadding) / kMultiple);
    size.height = floor(kHeight / kMultiple);
    return size;
}

- (CGSize)fitsSize {
    return [self sizeThatFits:CGSizeZero];
}

+ (UIImage *)coverImage {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = kSize;
        CGRect rect = (CGRect) {.size = size, .origin = CGPointZero};
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGPathRef boxPath = CGPathCreateWithRect(rect, NULL);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, kPadding + kRadius, kPadding);
        CGPathAddLineToPoint(path, NULL, size.width - kPadding - kRadius, kPadding);
        CGPathAddQuadCurveToPoint(path, NULL, size.width - kPadding, kPadding, size.width - kPadding, kPadding + kRadius);
        CGPathAddLineToPoint(path, NULL, size.width - kPadding, kHeight);
        CGPathAddCurveToPoint(path, NULL, size.width - kPadding, kPadding + kHeight, size.width - kPadding - kRadius, kPadding + kHeight, size.width - kPadding - kRadius, kPadding + kHeight);
        CGPathAddLineToPoint(path, NULL, size.width / 2 + kArrow, kPadding + kHeight);
        CGPathAddLineToPoint(path, NULL, size.width / 2, kPadding + kHeight + kArrow);
        CGPathAddLineToPoint(path, NULL, size.width / 2 - kArrow, kPadding + kHeight);
        CGPathAddLineToPoint(path, NULL, kPadding + kRadius, kPadding + kHeight);
        CGPathAddQuadCurveToPoint(path, NULL, kPadding, kPadding + kHeight, kPadding, kHeight);
        CGPathAddLineToPoint(path, NULL, kPadding, kPadding + kRadius);
        CGPathAddQuadCurveToPoint(path, NULL, kPadding, kPadding, kPadding + kRadius, kPadding);
        CGPathCloseSubpath(path);
        
        CGMutablePathRef arrowPath = CGPathCreateMutable();
        CGPathMoveToPoint(arrowPath, NULL, size.width / 2 - kArrow, MPITextCGFloatPixelFloor(kPadding) + kHeight);
        CGPathAddLineToPoint(arrowPath, NULL, size.width / 2 + kArrow, MPITextCGFloatPixelFloor(kPadding) + kHeight);
        CGPathAddLineToPoint(arrowPath, NULL, size.width / 2, kPadding + kHeight + kArrow);
        CGPathCloseSubpath(arrowPath);
        
        // inner shadow
        CGContextSaveGState(context); {
            CGFloat blurRadius = 25;
            CGSize offset = CGSizeMake(0, 15);
            CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.16].CGColor;
            CGColorRef opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
            CGContextAddPath(context, path);
            CGContextClip(context);
            CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
            CGContextBeginTransparencyLayer(context, NULL); {
                CGContextSetShadowWithColor(context, offset, blurRadius, opaqueShadowColor);
                CGContextSetBlendMode(context, kCGBlendModeSourceOut);
                CGContextSetFillColorWithColor(context, opaqueShadowColor);
                CGContextAddPath(context, path);
                CGContextFillPath(context);
            } CGContextEndTransparencyLayer(context);
            CGColorRelease(opaqueShadowColor);
        } CGContextRestoreGState(context);
        
        // outer shadow
        CGContextSaveGState(context); {
            CGContextAddPath(context, boxPath);
            CGContextAddPath(context, path);
            CGContextEOClip(context);
            CGColorRef shadowColor = [UIColor colorWithWhite:0 alpha:0.32].CGColor;
            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5), 3, shadowColor);
            CGContextBeginTransparencyLayer(context, NULL); {
                CGContextAddPath(context, path);
                [[UIColor colorWithWhite:0.7 alpha:1.000] setFill];
                CGContextFillPath(context);
            } CGContextEndTransparencyLayer(context);
        } CGContextRestoreGState(context);
        
        // arrow
        CGContextSaveGState(context); {
            CGContextAddPath(context, arrowPath);
            [[UIColor colorWithWhite:1 alpha:0.95] set];
            CGContextFillPath(context);
        } CGContextRestoreGState(context);
        
        // stroke
        CGContextSaveGState(context); {
            CGContextAddPath(context, path);
            [[UIColor colorWithWhite:0.6 alpha:1] setStroke];
            CGContextSetLineWidth(context, MPITextCGFloatFromPixel(1));
            CGContextStrokePath(context);
        } CGContextRestoreGState(context);
        
        CFRelease(boxPath);
        CFRelease(path);
        CFRelease(arrowPath);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

#undef kMultiple
#undef kSize
#undef kPadding
#undef kRadius
#undef kHeight
#undef kArrow

@end


@implementation MPITextMagnifier

+ (instancetype)magnifierWithType:(MPITextMagnifierType)type {
    switch (type) {
        case MPITextMagnifierTypeCaret :return [MPITextCaretMagnifier new];
        case MPITextMagnifierTypeRanged :return [MPITextRangedMagnifier new];
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    // class cluster
    if ([self isMemberOfClass:[MPITextMagnifier class]]) {
        @throw [NSException exceptionWithName:NSStringFromClass([self class]) reason:@"Attempting to instantiate an abstract class. Use a concrete subclass instead." userInfo:nil];
        return nil;
    }
    return [super initWithFrame:frame];
}

@end
