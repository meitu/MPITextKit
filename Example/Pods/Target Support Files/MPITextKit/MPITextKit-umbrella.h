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

#import "MPITextKit.h"
#import "MPITextAttachmentsInfo.h"
#import "MPITextBackgroundsInfo.h"
#import "MPITextDebugOption.h"
#import "MPITextInteractionManager.h"
#import "MPITextKitBugFixer.h"
#import "MPITextKitContext.h"
#import "MPITextLayoutManager.h"
#import "MPITextParser.h"
#import "MPITextRenderAttributes.h"
#import "MPITextRenderer.h"
#import "MPITextRendererKey.h"
#import "MPITextTailTruncater.h"
#import "MPITextTruncating.h"
#import "MPITextTruncationInfo.h"
#import "MPILabel.h"
#import "MPITextAsyncLayer.h"
#import "MPITextCache.h"
#import "MPITextEffectWindow.h"
#import "MPITextInput.h"
#import "MPITextInteractiveGestureRecognizer.h"
#import "MPITextMagnifier.h"
#import "MPITextSelectionView.h"
#import "MPITextSentinel.h"
#import "MPITextWeakProxy.h"
#import "MPITextAttachment.h"
#import "MPITextAttributes.h"
#import "MPITextBackedString.h"
#import "MPITextBackground.h"
#import "MPITextEntity.h"
#import "MPITextLink.h"
#import "NSAttributedString+MPITextKit.h"
#import "NSMutableAttributedString+MPITextKit.h"
#import "NSMutableParagraphStyle+MPITextKit.h"
#import "UIView+MPITextKit.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextHashing.h"
#import "MPITextKitConst.h"
#import "MPITextKitMacro.h"

FOUNDATION_EXPORT double MPITextKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MPITextKitVersionString[];

