//
//  MPITextLink.h
//  MeituMV
//
//  Created by Tpphha on 2018/9/21.
//  Copyright © 2018年 美图网. All rights reserved.
//

#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextEntity.h>
#else
#import "MPITextEntity.h"
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 The object that should be embedded with MPITextLinkAttributeName.
 */
@interface MPITextLink : MPITextEntity

+ (instancetype)linkWithValue:(id<NSObject>)value;

@end

NS_ASSUME_NONNULL_END
