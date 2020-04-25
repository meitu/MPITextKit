//
//  MPITextBackgroundsInfo.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextBackgroundsInfo.h"

@implementation MPITextBackgroundsInfo

- (instancetype)initWithBackgrounds:(NSArray<MPITextBackground *> *)backgrounds
               backgroundRectArrays:(NSArray<NSArray *> *)backgroundRectArrays
          backgroundCharacterRanges:(NSArray<NSValue *> *)backgroundCharacterRanges {
    self = [super init];
    if (self) {
        _backgrounds = backgrounds;
        _backgroundRectArrays = backgroundRectArrays;
        _backgroundCharacterRanges = backgroundCharacterRanges;
    }
    return self;
}

@end
