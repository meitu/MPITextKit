//
//  MPITextParser.h
//  MeituMV
//
//  Created by Tpphha on 2018/11/9.
//  Copyright © 2018 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPITextParser <NSObject>
@required
/**
 Parse text.

 @param text  The original attributed string. This method may parse the text and
 change the text attributes or content.
 
 @param selectedRange  Current selected range in `text`.
 This method should correct the range if the text content is changed. If there's
 no selected range, this value is NULL.
 
 @return If the 'text' is modified in this method, returns `YES`, otherwise returns `NO`.
 */
- (BOOL)parseText:(nullable NSMutableAttributedString *)text selectedRange:(nullable NSRangePointer)selectedRange;

@end

NS_ASSUME_NONNULL_END
