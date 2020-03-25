//
//  MPITextKitBugFixer.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Here solve the wrong line height problem of TextKit when have a mix
 layout of multi-languages like Chinese, English and emoji. This will
 have the same appearance with UILabel.
 
 The cause of wrong line height is from the differeces between fonts.
 For a mix text of Chinese and English with system defalut font, the
 Chinese will use `Pingfang SC` actucly and English with `SF UI`.
 */
@interface MPITextKitBugFixer : NSObject <NSLayoutManagerDelegate>

+ (instancetype)sharedFixer;

@end

NS_ASSUME_NONNULL_END
