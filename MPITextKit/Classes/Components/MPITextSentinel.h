//
//  MPITextSentinel.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

/// a thread safe incrementing counter.
@interface MPITextSentinel : NSObject

/// Returns the current value of the counter.
@property (atomic, readonly) int32_t value;

/// Increase the value atomically. @return The new value.
- (int32_t)increase;

@end
