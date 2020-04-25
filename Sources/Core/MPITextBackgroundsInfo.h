//
//  MPITextBackgroundsInfo.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MPITextBackground;

@interface MPITextBackgroundsInfo : NSObject

@property (nonatomic, strong, readonly) NSArray<MPITextBackground *> *backgrounds;
@property (nonatomic, strong, readonly) NSArray<NSArray *> *backgroundRectArrays;
@property (nonatomic, strong, readonly) NSArray<NSValue *> *backgroundCharacterRanges;

- (instancetype)initWithBackgrounds:(NSArray<MPITextBackground *> *)backgrounds
               backgroundRectArrays:(NSArray<NSArray *> *)backgroundRectArrays
          backgroundCharacterRanges:(NSArray<NSValue *> *)backgroundCharacterRanges;

@end

NS_ASSUME_NONNULL_END
