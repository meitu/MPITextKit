//
//  MPITextLineHeightFixer.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextKitBugFixer.h"
#import "MPITextKitConst.h"

@implementation MPITextKitBugFixer

+ (instancetype)sharedFixer {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {
    /**
     From apple's doc:
     https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html
     In addition to returning the line fragment rectangle itself, the layout manager returns a rectangle called the used rectangle. This is the portion of the line fragment rectangle that actually contains glyphs or other marks to be drawn. By convention, both rectangles include the line fragment padding and the interline space (which is calculated from the font’s line height metrics and the paragraph’s line spacing parameters). However, the paragraph spacing (before and after) and any space added around the text, such as that caused by center-spaced text, are included only in the line fragment rectangle, and are not included in the used rectangle.

     Althought the doc said usedRect should container lineSpacing,
     we don't add the lineSpacing to usedRect to avoid the case that
     last sentance have a extra lineSpacing pading.
     */
    NSTextStorage *textStorage = layoutManager.textStorage;
    NSRange characterRange = [layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];

    __block UIFont *maximumLineHeightFont = nil;
    __block CGFloat maximumLineHeight = 0;
    __block CGFloat maximumLineSpacing = 0;
    __block NSParagraphStyle *paragraphStyle = nil;
    [textStorage enumerateAttributesInRange:characterRange options:kNilOptions usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        UIFont *font = attrs[MPITextOriginalFontAttributeName]; // The actual height is NSOriginalFont lineHeight.
        if (!font) {
            font = attrs[NSFontAttributeName];
        }
        if (!paragraphStyle) {
            paragraphStyle = attrs[NSParagraphStyleAttributeName];
        }

        CGFloat lineHeight = [self lineHeightForFont:font paragraphStyle:paragraphStyle];
        if (lineHeight > maximumLineHeight) {
            maximumLineHeightFont = font;
            maximumLineHeight = lineHeight;
        }

        CGFloat lineSpacing = paragraphStyle.lineSpacing;
        if (lineSpacing > maximumLineSpacing) {
            maximumLineSpacing = lineSpacing;
        }
    }];
    
    // paragraphSpacing before
    CGFloat paragraphSpacingBefore = 0;
    if (glyphRange.location > 0) {
        if (paragraphStyle.paragraphSpacingBefore > FLT_EPSILON || paragraphStyle.paragraphSpacingBefore < -FLT_EPSILON) {
            NSRange lastLineEndRange = NSMakeRange(glyphRange.location - 1, 1);
            NSRange charaterRange = [layoutManager characterRangeForGlyphRange:lastLineEndRange actualGlyphRange:NULL];
            NSAttributedString *attributedString = [textStorage attributedSubstringFromRange:charaterRange];
            if ([attributedString.string isEqualToString:@"\n"]) {
                paragraphSpacingBefore = paragraphStyle.paragraphSpacingBefore;
            }
        }
    }

    // paragraphSpacing
    CGFloat paragraphSpacing = 0;
    if (paragraphStyle.paragraphSpacing > FLT_EPSILON) {
        NSRange charaterRange = [layoutManager characterRangeForGlyphRange:NSMakeRange(NSMaxRange(glyphRange) - 1, 1) actualGlyphRange:NULL];
        NSAttributedString *attributedString = [textStorage attributedSubstringFromRange:charaterRange];
        if ([attributedString.string isEqualToString:@"\n"]) {
            paragraphSpacing = paragraphStyle.paragraphSpacing;
        }
    }

    CGRect rect = *lineFragmentRect;
    CGRect usedRect = *lineFragmentUsedRect;

    CGFloat usedHeight = MAX(maximumLineHeight, usedRect.size.height);
    rect.size.height = paragraphSpacingBefore + usedHeight + maximumLineSpacing + paragraphSpacing;
    usedRect.size.height = usedHeight;

    *lineFragmentRect = rect;
    *lineFragmentUsedRect = usedRect;
    // When an attachment is included, it is wrong.
//    *baselineOffset = maximumParagraphSpacingBefore + maximumLineHeight + maximumLineHeightFont.descender;
    
    /**
     From apple's doc:
     YES if you modified the layout information and want your modifications to be used or NO if the original layout information should be used.
     But actually returning NO is also used. : )
     We should do this to solve the problem of exclusionPaths not working.
     */
    return NO;
}

// Implementing this method with a return value 0 will solve the problem of last line disappearing
// when both maxNumberOfLines and lineSpacing are set, since we didn't include the lineSpacing in
// the lineFragmentUsedRect.
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return 0;
}

#pragma mark - Utils

- (CGFloat)lineHeightForFont:(UIFont *)font paragraphStyle:(NSParagraphStyle *)style  {
    CGFloat lineHeight = font.lineHeight;
    if (!style) {
        return lineHeight;
    }
    if (style.lineHeightMultiple > FLT_EPSILON) {
        lineHeight *= style.lineHeightMultiple;
    }
    if (style.minimumLineHeight > FLT_EPSILON) {
        lineHeight = MAX(style.minimumLineHeight, lineHeight);
    }
    if (style.maximumLineHeight > FLT_EPSILON) {
        lineHeight = MIN(style.maximumLineHeight, lineHeight);
    }
    return lineHeight;
}

@end


