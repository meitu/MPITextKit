//
//  MPITextTruncationInfo.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/23.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextTruncationInfo.h"

@implementation MPITextTruncationInfo

- (instancetype)initWithTruncationCharacterRange:(NSValue *)truncationCharacterRange
                          visibleCharacterRanges:(NSArray<NSValue *> *)visibleCharacterRanges {
    self = [super init];
    if (self) {
        _truncationCharacterRange = truncationCharacterRange;
        _visibleCharacterRanges = visibleCharacterRanges;
    }
    return self;
}

@end
