//
//  NSString+MPIExample.h
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MPIExample)

- (NSString *)stringByAppendingNameScale:(CGFloat)scale;

- (NSString *)stringByAppendingPathScale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
