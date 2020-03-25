//
//  MPIExampleHelper.h
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIExampleHelper : NSObject

+ (void)addDebugOptionToViewController:(UIViewController *)viewController;
+ (void)setDebug:(BOOL)debug;
+ (BOOL)isDebug;

@end

NS_ASSUME_NONNULL_END
