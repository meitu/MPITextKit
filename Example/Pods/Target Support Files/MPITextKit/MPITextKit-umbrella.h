#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MPILabel.h"
#import "MPITextAsyncLayer.h"
#import "MPITextAttachment.h"
#import "MPITextAttachmentsInfo.h"
#import "MPITextAttributes.h"
#import "MPITextBackedString.h"
#import "MPITextBackground.h"
#import "MPITextBackgroundsInfo.h"
#import "MPITextCache.h"
#import "MPITextDebugOption.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextEffectWindow.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextHashing.h"
#import "MPITextInput.h"
#import "MPITextInteractionManager.h"
#import "MPITextInteractiveGestureRecognizer.h"
#import "MPITextKit.h"
#import "MPITextKitBugFixer.h"
#import "MPITextKitConst.h"
#import "MPITextKitContext.h"
#import "MPITextKitMacro.h"
#import "MPITextLayoutManager.h"
#import "MPITextLink.h"
#import "MPITextMagnifier.h"
#import "MPITextParser.h"
#import "MPITextRenderAttributes.h"
#import "MPITextRenderer.h"
#import "MPITextRendererKey.h"
#import "MPITextSelectionView.h"
#import "MPITextSentinel.h"
#import "MPITextTailTruncater.h"
#import "MPITextTruncating.h"
#import "MPITextTruncationInfo.h"
#import "NSAttributedString+MPITextKit.h"
#import "NSMutableAttributedString+MPITextKit.h"
#import "NSMutableParagraphStyle+MPITextKit.h"
#import "UIView+MPITextKit.h"

FOUNDATION_EXPORT double MPITextKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MPITextKitVersionString[];

