//
//  UIView+MPITextKit.h
//  MPITextKit
//
//  Created by Tpphha on 2020/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MPITextKit)

- (CGPoint)mpi_convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;

- (CGPoint)mpi_convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;

- (CGRect)mpi_convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;

- (CGRect)mpi_convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
