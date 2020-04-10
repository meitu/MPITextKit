//
//  MPITextRenderAttributes.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPITextRenderAttributes : NSObject <NSCopying>

/**
 Default is nil.
 */
@property (nullable, nonatomic, strong) NSAttributedString *attributedText;

/**
 Default is NSLineBreakByTruncatingTail.
 */
@property (nonatomic) NSLineBreakMode lineBreakMode;

/**
 Default is 1.
 */
@property (nonatomic) NSUInteger maximumNumberOfLines;

/**
 Default is nil.
 */
@property (nullable, nonatomic, strong) NSArray<UIBezierPath *> *exclusionPaths;

/**
 Default is nil.
 Note: You should use MPITextTruncationAttributedTextWithTokenAndAdditionalMessage() to get it.
 */
@property (nullable, nonatomic, strong) NSAttributedString *truncationAttributedText;

@end

NS_ASSUME_NONNULL_END
