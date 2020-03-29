//
//  MPITextAttributesViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAttributesViewController.h"
#import <MPITextKit/MPITextKit.h>
#import "MPIExampleHelper.h"

@interface MPITextAttributesViewController () <MPILabelDelegate>

@end

@implementation MPITextAttributesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    MPILabel *label = [MPILabel new];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    label.delegate = self;
    label.frame = self.view.bounds;
    [self.view addSubview:label];
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    
    {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = [UIColor colorWithWhite:0.000 alpha:0.490];
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowBlurRadius = 5;
        NSMutableAttributedString *one =
        [[NSMutableAttributedString alloc] initWithString:@"Shadow" attributes:@{
                                                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:30],
                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                 NSShadowAttributeName: shadow
                                                                                 }];
        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
    }

    {
        MPITextBackground *background = [MPITextBackground backgroundWithFillColor:[UIColor colorWithRed:1.000 green:0.795 blue:0.014 alpha:1.000] cornerRadius:3];
        background.borderColor = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
        background.borderWidth = 3;
        background.insets = UIEdgeInsetsMake(0, -4, 0, -4);
        NSMutableAttributedString *one =
        [[NSMutableAttributedString alloc] initWithString:@"Background" attributes:@{
                                                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:30],
                                                                                     NSForegroundColorAttributeName: [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000],
                                                                                     MPITextBackgroundAttributeName: background
                                                                                 }];

        [text appendAttributedString:[self padding]];
        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
    }

    {
        MPITextLink *link = [MPITextLink new];
        link.value = @"I am a link.";
        MPITextBackground *background = [MPITextBackground backgroundWithFillColor:[UIColor colorWithWhite:0.000 alpha:0.220] cornerRadius:3];
        NSMutableAttributedString *one =
        [[NSMutableAttributedString alloc] initWithString:@"Link" attributes:@{
                                                                               NSFontAttributeName: [UIFont boldSystemFontOfSize:30],
                                                                               NSForegroundColorAttributeName: [UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000],
                                                                               MPITextBackgroundAttributeName: background,
                                                                               MPITextLinkAttributeName: link
                                                                               }];

        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];

    }

    {
        MPITextLink *link = [MPITextLink new];
        link.value = @"I am a link.";
        MPITextBackground *background = [MPITextBackground backgroundWithFillColor:[UIColor colorWithWhite:0.000 alpha:0.220] cornerRadius:3];
        NSMutableAttributedString *one =
        [[NSMutableAttributedString alloc] initWithString:@"Strikethrough" attributes:@{
                                                                               NSFontAttributeName: [UIFont boldSystemFontOfSize:30],
                                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                               MPITextBackgroundAttributeName: background,
                                                                               MPITextLinkAttributeName: link,
                                                                               NSStrikethroughStyleAttributeName: @(YES),
                                                                               NSStrikethroughColorAttributeName: [UIColor blackColor]
                                                                               }];

        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
    }

    {
        MPITextLink *link = [MPITextLink new];
        link.value = @"I am a link.";
        MPITextBackground *background = [MPITextBackground backgroundWithFillColor:[UIColor colorWithWhite:0.000 alpha:0.220] cornerRadius:3];
        NSMutableAttributedString *one =
        [[NSMutableAttributedString alloc] initWithString:@"Underline" attributes:@{
                                                                                        NSFontAttributeName: [UIFont boldSystemFontOfSize:30],
                                                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                        MPITextBackgroundAttributeName: background,
                                                                                        MPITextLinkAttributeName: link,
                                                                                        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                                        NSUnderlineColorAttributeName: [UIColor redColor]
                                                                                        }];

        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
        [text appendAttributedString:[self padding]];
    }

    [text mpi_setAlignment:NSTextAlignmentCenter range:text.mpi_rangeOfAll];
    
    {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.firstLineHeadIndent = 15;
        paragraphStyle.headIndent = 15;
        paragraphStyle.tailIndent = -3;
        MPITextBackground *background = [MPITextBackground new];
        background.borderWidth = 4;
        background.borderColor = [UIColor lightGrayColor];
        background.borderEdges = UIRectEdgeLeft;
        background.insets = UIEdgeInsetsMake(0, 8, 0, 0);
        background.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        NSString *quote = @"『《我的阿勒泰》是作者十年来散文创作的合集。分为阿勒泰文字、阿勒泰角落和九篇雪三辑。这是一部描写疆北阿勒泰地区生活和风情的原生态散文集。充满生机活泼、新鲜动人的元素。记录作者在疆北阿勒泰地区生活的点滴，包括人与事的记忆。作者在十年前以天才的触觉和笔调初现文坛并引起震惊。作品风格清新、明快，质地纯粹，原生态地再现了疆北风物，带着非常活泼的生机。』";
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:quote
                                                                                attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCallout],
                                                                                             NSParagraphStyleAttributeName: paragraphStyle,
                                                                                             MPITextBlockBackgroundAttributeName: background}];
        MPITextLink *bookLink = [MPITextLink linkWithValue:[NSURL URLWithString:@"https://book.douban.com/subject/4884218/"]];
        NSRange bookRange = [quote rangeOfString:@"《我的阿勒泰》"];
        MPITextBackground *linkBackground = [MPITextBackground backgroundWithFillColor:[UIColor colorWithWhite:0.000 alpha:0.220] cornerRadius:3];
        [one addAttribute:MPITextBackgroundAttributeName value:linkBackground range:bookRange];
        [one addAttribute:MPITextLinkAttributeName value:bookLink range:bookRange];
        [one addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000] range:bookRange];
        [text appendAttributedString:one];
        [text appendAttributedString:[self padding]];
    }
    
    label.attributedText = text;
}

- (NSAttributedString *)padding {
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n\n" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:4]}];
    return pad;
}

- (void)showMessage:(NSString *)msg {
    CGFloat padding = 10;
    
    MPILabel *label = [MPILabel new];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.033 green:0.685 blue:0.978 alpha:0.730];
    label.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    label.layer.cornerRadius = 5;
    [label sizeToFit];
    CGPoint center = self.view.center;
    center.y = 128;
    label.center = center;
    [self.view addSubview:label];
    
    label.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}

#pragma mark - MPILabelDelegate

- (NSDictionary *)label:(MPILabel *)label highlightedTextAttributesWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange {
    MPITextBackground *background = [MPITextBackground backgroundWithFillColor:[UIColor redColor] cornerRadius:3];
    background.borderColor = [UIColor colorWithRed:1.000 green:0.029 blue:0.651 alpha:1.000];
    background.borderWidth = 3;
    return @{MPITextBackgroundAttributeName: background};
}

- (void)label:(MPILabel *)label didInteractWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange interaction:(MPITextItemInteraction)interaction {
    [self showMessage:[NSString stringWithFormat:@"%@: %@",
                       interaction == MPITextItemInteractionTap ? @"Tapped" : @"Long pressed",
                       [attributedText attributedSubstringFromRange:characterRange].string]];
    if ([link.value isKindOfClass:NSURL.class]) {
        [UIApplication.sharedApplication openURL:link.value options:@{} completionHandler:nil];
    }
}

@end
