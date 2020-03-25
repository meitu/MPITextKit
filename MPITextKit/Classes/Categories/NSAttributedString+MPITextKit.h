//
//  NSAttributedString+MPITextKit.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (MPITextKit)

- (NSRange)mpi_rangeOfAll;

/**
 Returns the plain text from a range.
 If there's `MPITextBackedStringAttributeName` attribute, the backed string will
 replace the attributed string range.
 
 @param range A range in receiver.
 @return The plain text.
 */
- (nullable NSString *)mpi_plainTextForRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
