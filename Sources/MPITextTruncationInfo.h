//
//  MPITextTruncationInfo.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPITextRenderer;

@interface MPITextTruncationInfo : NSObject

@property (nonatomic, strong, readonly) NSValue *truncationCharacterRange;

/**
 The character range from the original attributedString that is displayed by the renderer given the parameters in the initializer.
 */
@property (nonatomic, strong, readonly) NSArray<NSValue *> *visibleCharacterRanges;

- (instancetype)initWithTruncationCharacterRange:(NSValue *)truncationCharacterRange
                          visibleCharacterRanges:(NSArray<NSValue *> *)visibleCharacterRanges;

@end

NS_ASSUME_NONNULL_END
