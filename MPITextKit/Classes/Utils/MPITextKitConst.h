//
//  MPITextKitConst.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#ifndef MPITextKitConst_h
#define MPITextKitConst_h
#import <UIKit/UIKit.h>

/**
 Text vertical alignment.
 */
typedef NS_ENUM(NSInteger, MPITextVerticalAlignment) {
    MPITextVerticalAlignmentTop =    0, ///< Top alignment.
    MPITextVerticalAlignmentCenter = 1, ///< Center alignment.
    MPITextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

typedef NS_ENUM(NSInteger, MPITextItemInteraction) {
    MPITextItemInteractionPossible,
    MPITextItemInteractionTap,
    MPITextItemInteractionLongPress,
};

typedef NS_ENUM(NSInteger, MPITextSelectionGrabberType) {
    MPITextSelectionGrabberTypeNone,
    MPITextSelectionGrabberTypeStart,
    MPITextSelectionGrabberTypeEnd
};

typedef NS_ENUM(NSInteger, MPITextMenuType) {
    MPITextMenuTypeNone,
    MPITextMenuTypeSystem,
    MPITextMenuTypeCustom
};

FOUNDATION_EXTERN const CGSize MPITextContainerMaxSize;

UIKIT_EXTERN NSAttributedStringKey const MPITextLinkAttributeName NS_SWIFT_NAME(MPILink); ///< Attribute name for links. The value must be MPITextLink object.
UIKIT_EXTERN NSAttributedStringKey const MPITextBackgroundAttributeName NS_SWIFT_NAME(MPIBackground);
UIKIT_EXTERN NSAttributedStringKey const MPITextBlockBackgroundAttributeName NS_SWIFT_NAME(MPIBlockBackground);
UIKIT_EXTERN NSAttributedStringKey const MPITextBackedStringAttributeName NS_SWIFT_NAME(MPIBackedString);
UIKIT_EXTERN NSAttributedStringKey const MPITextHighlightedAttributeName NS_SWIFT_NAME(MPIHighlighted);
UIKIT_EXTERN NSAttributedStringKey const MPITextOriginalFontAttributeName NS_SWIFT_NAME(MPIOriginalFont); ///< You shouldn't use it.

#endif /* MPITextKitConst_h */
