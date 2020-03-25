//
//  NSMutableAttributedString+MPITextKit.h
//  MeituMV
//
//  Created by Tpphha on 2019/1/21.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (MPITextKit)

- (void)mpi_setAttribute:(NSString *)name value:(id)value range:(NSRange)range;

- (void)mpi_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range;

- (void)mpi_setAlignment:(NSTextAlignment)alignment range:(NSRange)range;

- (void)mpi_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range;

- (void)mpi_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range;

- (void)mpi_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range;

- (void)mpi_setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range;

- (void)mpi_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range;

- (void)mpi_setHeadIndent:(CGFloat)headIndent range:(NSRange)range;

- (void)mpi_setTailIndent:(CGFloat)tailIndent range:(NSRange)range;

- (void)mpi_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range;

- (void)mpi_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range;

- (void)mpi_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range;

- (void)mpi_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range;

- (void)mpi_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range;

- (void)mpi_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range;

- (void)mpi_setTabStops:(NSArray *)tabStops range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
