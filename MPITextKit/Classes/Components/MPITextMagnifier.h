//
//  MPITextMagnifier.h
//  MPITextKit
//
//  Created by Tpphha on 2020/3/8.
//

#import <UIKit/UIKit.h>

/// Magnifier type
typedef NS_ENUM(NSInteger, MPITextMagnifierType) {
    MPITextMagnifierTypeCaret,  ///< Circular magnifier
    MPITextMagnifierTypeRanged, ///< Round rectangle magnifier
};

NS_ASSUME_NONNULL_BEGIN

/**
A magnifier view which can be displayed in `MPITextEffectWindow`.

@discussion Use `magnifierWithType:` to create instance.
Typically, you should not use this class directly.
*/
@interface MPITextMagnifier : UIView

/// Create a mangifier with the specified type. @param type The magnifier type.
+ (instancetype)magnifierWithType:(MPITextMagnifierType)type;

@property (nonatomic, readonly) MPITextMagnifierType type;  ///< Type of magnifier
@property (nonatomic, readonly) CGSize fitsSize;            ///< The 'best' size for magnifier view.
@property (nonatomic, readonly) CGSize snapshotSize;       ///< The 'best' snapshot image size for magnifier.
@property (nullable, nonatomic, strong) UIImage *snapshot; ///< The image in magnifier (readwrite).

@property (nullable, nonatomic, weak) UIView *hostView;   ///< The coordinate based view.
@property (nonatomic) CGPoint hostCaptureCenter;          ///< The snapshot capture center in `hostView`.
@property (nonatomic) CGPoint hostPopoverCenter;          ///< The popover center in `hostView`.
@property (nonatomic) BOOL hostVerticalForm;              ///< The host view is vertical form.
@property (nonatomic) BOOL captureDisabled;               ///< A hint for `MPITextEffectWindow` to disable capture.
@property (nonatomic) BOOL captureFadeAnimation;          ///< Show fade animation when the snapshot image changed.

@end

NS_ASSUME_NONNULL_END
