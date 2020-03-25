//
//  MPITextGeometryHelpers.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXTERN CGRect MPITextCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode);

/// Get main screen's scale.
FOUNDATION_EXTERN CGFloat MPITextScreenScale(void);

/// Get main screen's size. Height is always larger than width.
FOUNDATION_EXTERN CGSize MPITextScreenSize(void);

/// Get one pixel.
FOUNDATION_EXTERN CGFloat MPITextOnePixel(void);

FOUNDATION_EXTERN CGAffineTransform MPITextCGAffineTransformGetFromViews(UIView *from, UIView *to);

FOUNDATION_EXTERN CGAffineTransform MPITextCGAffineTransformGetFromPoints(CGPoint before[3], CGPoint after[3]);

/// Convert degrees to radians.
static inline CGFloat MPITextDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}

/// Convert radians to degrees.
static inline CGFloat MPITextRadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

/// Get the transform rotation.
/// @return the rotation in radians [-PI,PI] ([-180°,180°])
static inline CGFloat MPITextCGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// Convert point to pixel.
static inline CGFloat MPITextCGFloatToPixel(CGFloat value) {
    return value * MPITextScreenScale();
}

/// Convert pixel to point.
static inline CGFloat MPITextCGFloatFromPixel(CGFloat value) {
    return value / MPITextScreenScale();
}

/// floor point value for pixel-aligned
static inline CGFloat MPITextCGFloatPixelFloor(CGFloat value) {
    CGFloat scale = MPITextScreenScale();
    return floor(value * scale) / scale;
}

/// round point value for pixel-aligned
static inline CGFloat MPITextCGFloatPixelRound(CGFloat value) {
    CGFloat scale = MPITextScreenScale();
    return round(value * scale) / scale;
}

/// ceil point value for pixel-aligned
static inline CGFloat MPITextCGFloatPixelCeil(CGFloat value) {
    CGFloat scale = MPITextScreenScale();
    return ceil((value - FLT_EPSILON) * scale) / scale;
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGFloat MPITextCGFloatPixelHalf(CGFloat value) {
    CGFloat scale = MPITextScreenScale();
    return (floor(value * scale) + 0.5) / scale;
}

/// floor point value for pixel-aligned
static inline CGPoint MPITextCGPointPixelFloor(CGPoint point) {
    CGFloat scale = MPITextScreenScale();
    return CGPointMake(floor(point.x * scale) / scale,
                       floor(point.y * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGPoint MPITextCGPointPixelRound(CGPoint point) {
    CGFloat scale = MPITextScreenScale();
    return CGPointMake(round(point.x * scale) / scale,
                       round(point.y * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGPoint MPITextCGPointPixelCeil(CGPoint point) {
    CGFloat scale = MPITextScreenScale();
    return CGPointMake(ceil(point.x * scale) / scale,
                       ceil(point.y * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGPoint MPITextCGPointPixelHalf(CGPoint point) {
    CGFloat scale = MPITextScreenScale();
    return CGPointMake((floor(point.x * scale) + 0.5) / scale,
                       (floor(point.y * scale) + 0.5) / scale);
}

/// Returns the distance between two points.
static inline CGFloat MPITextCGPointGetDistanceToPoint(CGPoint p1, CGPoint p2) {
    return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

/// floor point value for pixel-aligned
static inline CGSize MPITextCGSizePixelFloor(CGSize size) {
    CGFloat scale = MPITextScreenScale();
    return CGSizeMake(floor(size.width * scale) / scale,
                      floor(size.height * scale) / scale);
}

/// round point value for pixel-aligned
static inline CGSize MPITextCGSizePixelRound(CGSize size) {
    CGFloat scale = MPITextScreenScale();
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

/// ceil point value for pixel-aligned
static inline CGSize MPITextCGSizePixelCeil(CGSize size) {
    CGFloat scale = MPITextScreenScale();
    return CGSizeMake(ceil(size.width * scale) / scale,
                      ceil(size.height * scale) / scale);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGSize MPITextCGSizePixelHalf(CGSize size) {
    CGFloat scale = MPITextScreenScale();
    return CGSizeMake((floor(size.width * scale) + 0.5) / scale,
                      (floor(size.height * scale) + 0.5) / scale);
}

/// Returns the area of the rectangle.
static inline CGFloat MPITextCGRectGetArea(CGRect rect) {
    if (CGRectIsNull(rect)) return 0;
    rect = CGRectStandardize(rect);
    return rect.size.width * rect.size.height;
}

/// Returns the minmium distance between a point to a rectangle.
static inline CGFloat  MPITextCGPointGetDistanceToRect(CGPoint p, CGRect r) {
    r = CGRectStandardize(r);
    if (CGRectContainsPoint(r, p)) return 0;
    CGFloat distV, distH;
    if (CGRectGetMinY(r) <= p.y && p.y <= CGRectGetMaxY(r)) {
        distV = 0;
    } else {
        distV = p.y < CGRectGetMinY(r) ? CGRectGetMinY(r) - p.y : p.y - CGRectGetMaxY(r);
    }
    if (CGRectGetMinX(r) <= p.x && p.x <= CGRectGetMaxX(r)) {
        distH = 0;
    } else {
        distH = p.x < CGRectGetMinX(r) ? CGRectGetMinX(r) - p.x : p.x - CGRectGetMaxX(r);
    }
    return MAX(distV, distH);
}

/// floor point value for pixel-aligned
static inline CGRect MPITextCGRectPixelFloor(CGRect rect) {
    CGPoint origin = MPITextCGPointPixelCeil(rect.origin);
    CGPoint corner = MPITextCGPointPixelFloor(CGPointMake(rect.origin.x + rect.size.width,
                                                          rect.origin.y + rect.size.height));
    CGRect ret = CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
    if (ret.size.width < 0) ret.size.width = 0;
    if (ret.size.height < 0) ret.size.height = 0;
    return ret;
}

/// round point value for pixel-aligned
static inline CGRect MPITextCGRectPixelRound(CGRect rect) {
    CGPoint origin = MPITextCGPointPixelRound(rect.origin);
    CGPoint corner = MPITextCGPointPixelRound(CGPointMake(rect.origin.x + rect.size.width,
                                                          rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// ceil point value for pixel-aligned
static inline CGRect MPITextCGRectPixelCeil(CGRect rect) {
    CGPoint origin = MPITextCGPointPixelFloor(rect.origin);
    CGPoint corner = MPITextCGPointPixelCeil(CGPointMake(rect.origin.x + rect.size.width,
                                                         rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// round point value to .5 pixel for path stroke (odd pixel line width pixel-aligned)
static inline CGRect MPITextCGRectPixelHalf(CGRect rect) {
    CGPoint origin = MPITextCGPointPixelHalf(rect.origin);
    CGPoint corner = MPITextCGPointPixelHalf(CGPointMake(rect.origin.x + rect.size.width,
                                                         rect.origin.y + rect.size.height));
    return CGRectMake(origin.x, origin.y, corner.x - origin.x, corner.y - origin.y);
}

/// Returns the center for the rectangle.
static inline CGPoint MPITextCGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

/// floor UIEdgeInset for pixel-aligned
static inline UIEdgeInsets MPITextUIEdgeInsetPixelFloor(UIEdgeInsets insets) {
    insets.top = MPITextCGFloatPixelFloor(insets.top);
    insets.left = MPITextCGFloatPixelFloor(insets.left);
    insets.bottom = MPITextCGFloatPixelFloor(insets.bottom);
    insets.right = MPITextCGFloatPixelFloor(insets.right);
    return insets;
}

/// ceil UIEdgeInset for pixel-aligned
static inline UIEdgeInsets MPITextUIEdgeInsetPixelCeil(UIEdgeInsets insets) {
    insets.top = MPITextCGFloatPixelCeil(insets.top);
    insets.left = MPITextCGFloatPixelCeil(insets.left);
    insets.bottom = MPITextCGFloatPixelCeil(insets.bottom);
    insets.right = MPITextCGFloatPixelCeil(insets.right);
    return insets;
}

/// UIEdgeInsets horizontal value.
static inline CGFloat MPITextUIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

/// UIEdgeInsets vertical value.
static inline CGFloat MPITextUIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

