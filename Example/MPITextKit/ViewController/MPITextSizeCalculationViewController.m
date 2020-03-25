//
//  MPITextSizeCalculationViewController.m
//  MPITextKit_Example
//
//  Created by ; on 2020/3/24.
//  Copyright © 2020 美图网. All rights reserved.
//

#import "MPITextSizeCalculationViewController.h"
#import "MPIExampleHelper.h"
@import MPITextKit;

@interface MPITextSizeCalculationViewController ()

@end

@implementation MPITextSizeCalculationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    NSString *text = @"Here’s to the crazy ones, the misfits, the rebels, the troublemakers, the round pegs in the square holes… the ones who see things differently — they’re not fond of rules… You can quote them, disagree with them, glorify or vilify them, but the only thing you can’t do is ignore them because they change things… they push the human race forward, and while some may see them as the crazy ones, we see genius, because the ones who are crazy enough to think that they can change the world, are the ones who do.";
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
    NSAttributedString *token = MPITextDefaultTruncationAttributedToken();
    NSAttributedString *additionalMessage =
    [[NSAttributedString alloc] initWithString:@"more" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.000 green:0.449 blue:1.000 alpha:1.000], MPITextLinkAttributeName: [MPITextLink new]}];
    NSAttributedString *truncationAttriubtedText = MPITextTruncationAttributedTextWithTokenAndAdditionalMessage(attributedText, token, additionalMessage);
    CGSize fitsSize = CGSizeMake(CGRectGetWidth(self.view.frame) - 30, CGFLOAT_MAX);
    // You can change it for testing
    NSUInteger numberOfLines = 5;
     
    MPITextRenderAttributes *renderAttributes = [MPITextRenderAttributes new];
    renderAttributes.attributedText = attributedText;
    renderAttributes.truncationAttributedText = truncationAttriubtedText;
    renderAttributes.maximumNumberOfLines = numberOfLines;
    CGSize textSize = MPITextSuggestFrameSizeForAttributes(renderAttributes, fitsSize, UIEdgeInsetsZero);
    
    MPILabel *label = [MPILabel new];
    label.attributedText = attributedText;
    label.truncationAttributedToken = token;
    label.additionalTruncationAttributedMessage = additionalMessage;
    label.numberOfLines = numberOfLines;
    CGSize labelSize = [label sizeThatFits:fitsSize];
    CGRect labelFrame = (CGRect){ .size = labelSize };
    label.frame = labelFrame;
    label.center = self.view.center;
    [self.view addSubview:label];
    
    NSAssert(CGSizeEqualToSize(textSize, labelSize), @"They have to be the same size.");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
