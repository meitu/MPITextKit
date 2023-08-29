//
//  MPITextSentinel.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextSentinel.h"
#import <stdatomic.h>

@interface MPITextSentinel () {
    atomic_long _counter;
}

@end

@implementation MPITextSentinel

- (long)increase {
    return atomic_fetch_add_explicit(&_counter, 1, memory_order_relaxed) + 1;
}

- (long)value {
    return _counter;
}

@end
