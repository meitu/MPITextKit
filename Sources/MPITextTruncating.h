//
//  MPITextTruncating.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#ifndef MPITextTruncating_h
#define MPITextTruncating_h

#import <UIKit/UIKit.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextTruncationInfo.h>
#else
#import "MPITextTruncationInfo.h"
#endif

@class MPITextLayoutManager;

NS_ASSUME_NONNULL_BEGIN

@protocol MPITextTruncating <NSObject>

/**
 A truncater object is initialized with the full state of the text.  It is a Single Responsibility Object that is
 mutative.  It configures the state of the TextKit components (layout manager, text container, text storage) to achieve
 the intended truncation, then it stores the resulting state for later fetching.
 
 The truncater may mutate the state of the text storage such that only the drawn string is actually present in the
 text storage itself.
 
 The truncater should not store a strong reference to the context to prevent retain cycles.
 */
- (instancetype)initWithTruncationAttributedString:(nullable NSAttributedString *)truncationAttributedString
         avoidTailTruncationSet:(nullable NSCharacterSet *)avoidTailTruncationSet;

/**
 Actually do the truncation.

 @param layoutManager layoutManager
 @param textStorage textStorage
 @param textContainer textContainer
 */
- (nullable MPITextTruncationInfo *)truncateWithLayoutManager:(MPITextLayoutManager *)layoutManager
                                                  textStorage:(NSTextStorage *)textStorage
                                                textContainer:(NSTextContainer *)textContainer;


@end

NS_ASSUME_NONNULL_END


#endif /* MPITextTruncating_h */
