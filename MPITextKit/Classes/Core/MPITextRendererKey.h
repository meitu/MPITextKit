//
//  MPITextRendererKey.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MPITextRenderAttributes;

NS_ASSUME_NONNULL_BEGIN

@interface MPITextRendererKey : NSObject

@property (nonatomic, readonly) MPITextRenderAttributes *attributes;
@property (nonatomic, readonly) CGSize constrainedSize;

- (instancetype)initWithAttributes:(MPITextRenderAttributes *)attributes constrainedSize:(CGSize)constrainedSize;

@end

NS_ASSUME_NONNULL_END
