//
//  MPITextBackedString.h
//  MeituMV
//
//  Created by Tpphha on 2018/11/9.
//  Copyright © 2018 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
MPITextBackedString objects are used by the NSAttributedString class cluster
as the values for text backed string attributes (stored in the attributed
string under the key named MPITextBackedStringAttributeName).

It may used for copy/paste plain text from attributed string.
Example: If :) is replace by a custom emoji (such as😊), the backed string can be set to @":)".
*/
@interface MPITextBackedString : NSObject <NSCopying, NSCoding>

@property (nullable, nonatomic, copy) NSString *string; ///< backed text

- (instancetype)initWithString:(nullable NSString *)string;

+ (instancetype)stringWithString:(nullable NSString *)string;

@end

NS_ASSUME_NONNULL_END
