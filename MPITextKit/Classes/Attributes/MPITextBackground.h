//
//  MPITextBorder.h
//  MeituMV
//
//  Created by Tpphha on 2018/8/14.
//  Copyright © 2018年 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// It can be used to draw a background to a range of text.
/// stored in the attributed string under the key named MPITextBackgroundAttributeName or MPITextBlockBackgroundAttributeName.
@interface MPITextBackground : NSObject

/// border line width
@property (nonatomic) CGFloat borderWidth;

/// border line color
@property (nullable, nonatomic, strong) UIColor *borderColor;

/// border edges, default UIRectEdgeAll
@property (nonatomic) UIRectEdge borderEdges;

/// border line join
@property (nonatomic) CGLineJoin lineJoin;

/// border line cap
@property (nonatomic) CGLineCap lineCap;

/// background insets for text bounds
@property (nonatomic) UIEdgeInsets insets;

/// background corder radius
/// NOTE: When it works on borders only if borderEdges is UIRectEdgeAll.
@property (nonatomic) CGFloat cornerRadius;

/// inner fill color
@property (nullable, nonatomic, strong) UIColor *fillColor;

+ (instancetype)backgroundWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;

/**
 If the background across multiple lines, this method will be called multiple times.

 @param textContainer textContainer
 @param proposedRect proposed rect.
 @param characterRange characterRange.
 @return The rect to be applied.
 */
- (CGRect)backgroundRectForTextContainer:(NSTextContainer *)textContainer
                            proposedRect:(CGRect)proposedRect
                          characterRange:(NSRange)characterRange NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
