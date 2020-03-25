//
//  NSMutableParagraphStyle+MPITextKit.h
//  MeituMV
//
//  Created by Tpphha on 2019/1/21.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableParagraphStyle (MPITextKit)

+ (instancetype)mpi_styleWithCTStyle:(CTParagraphStyleRef)CTStyle;

@end

NS_ASSUME_NONNULL_END
