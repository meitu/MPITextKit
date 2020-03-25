//
//  MPITextKitContext.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextKitContext.h"
#import "MPITextThread.h"
#import "MPITextKitBugFixer.h"
#import "MPITextKitConst.h"

@interface MPITextKitContext ()

@property (nonatomic, strong) MPITextLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation MPITextKitContext {
    // All TextKit operations (even non-mutative ones) must be executed serially.
    std::shared_ptr<MPITextKit::Mutex> __instanceLock__;
}

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                    maximumNumberOfLines:(NSUInteger)maximumNumberOfLines
                          exclusionPaths:(NSArray *)exclusionPaths
                         constrainedSize:(CGSize)constrainedSize

{
    if (self = [super init]) {
        // Concurrently initialising TextKit components crashes (rdar://18448377) so we use a global lock.
        // Allocate __staticMutex on the heap to prevent destruction at app exit (https://github.com/TextureGroup/Texture/issues/136)
        static MPITextKit::StaticMutex& __staticMutex = *new MPITextKit::StaticMutex;
        MPITextKit::StaticMutexLocker l(__staticMutex);
        
        __instanceLock__ = std::make_shared<MPITextKit::Mutex>();
        
        // Create the TextKit component stack with our default configuration.
        _layoutManager = [[MPITextLayoutManager alloc] init];
        _layoutManager.usesFontLeading = NO;
        _layoutManager.delegate = [MPITextKitBugFixer sharedFixer];
        
        _textContainer = [[NSTextContainer alloc] initWithSize:constrainedSize];
        // We want the text laid out up to the very edges of the container.
        _textContainer.lineFragmentPadding = 0;
        _textContainer.lineBreakMode = lineBreakMode;
        _textContainer.maximumNumberOfLines = maximumNumberOfLines;
        _textContainer.exclusionPaths = exclusionPaths;
        [_layoutManager addTextContainer:_textContainer];
        
        // CJK language layout issues.
        NSMutableAttributedString *attributedText = attributedString.mutableCopy;
        [attributedText enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedText.length) options:kNilOptions usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (value) {
                [attributedText addAttribute:MPITextOriginalFontAttributeName value:value range:range];
            }
        }];
        _textStorage = attributedText ? [[NSTextStorage alloc] initWithAttributedString:attributedText] : [NSTextStorage new];
        [_textStorage addLayoutManager:_layoutManager];
    }
    return self;
}

- (void)performBlockWithLockedTextKitComponents:(void (^)(MPITextLayoutManager *,
                                                          NSTextStorage *,
                                                          NSTextContainer *))block
{
    MPITextKit::MutexSharedLocker l(__instanceLock__);
    if (block) {
        block(_layoutManager, _textStorage, _textContainer);
    }
}

@end
