//
//  MPITextEffectWindow.h
//  MPITextKit
//
//  Created by Tpphha on 2020/3/22.
//

#import <UIKit/UIKit.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextMagnifier.h>
#else
#import "MPITextMagnifier.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MPITextEffectWindow : UIWindow

/// Returns the shared instance (returns nil in App Extension).
+ (nullable instancetype)sharedWindow;

/// Show the magnifier in this window with a 'popup' animation. @param magnifier A magnifier.
- (void)showMagnifier:(MPITextMagnifier *)magnifier;
/// Update the magnifier content and position. @param magnifier A magnifier.
- (void)moveMagnifier:(MPITextMagnifier *)magnifier;
/// Remove the magnifier from this window with a 'shrink' animation. @param magnifier A magnifier.
- (void)hideMagnifier:(MPITextMagnifier *)magnifier;

@end

NS_ASSUME_NONNULL_END
