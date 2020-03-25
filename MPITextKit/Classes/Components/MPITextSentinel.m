//
//  MPITextSentinel.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextSentinel.h"
#import <libkern/OSAtomic.h>
#import <stdatomic.h>

@implementation MPITextSentinel

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
