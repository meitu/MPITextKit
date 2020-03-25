//
//  MPITextSelectionViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2020/3/20.
//  Copyright © 2020 美图网. All rights reserved.
//

#import "MPITextSelectionViewController.h"
#import "MPIExampleHelper.h"
@import MPITextKit;

@interface MPITextSelectionLabel : MPILabel

@end

@implementation MPITextSelectionLabel

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return
    action == @selector(copy:) ||
    (action == @selector(selectAll:) ? !NSEqualRanges(self.selectedRange, NSMakeRange(0, self.attributedText.length)) : NO) ||
    action == @selector(hello:);
}

- (void)selectAll:(id)sender {
    [self hideMenu];
    self.selectedRange = NSMakeRange(0, self.attributedText.length);
    [self showMenu];
}

- (void)hello:(id)sender {
    NSLog(@"Hello");
}

@end

@interface MPITextSelectionViewController () <MPILabelDelegate>

@end

@implementation MPITextSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    NSString *text = @"The UIKit framework includes several classes whose purpose is to display text in an app’s user interface: UITextView, UITextField, and UILabel, as described in Displaying Text Content in iOS. Text views, created from the UITextView class, are meant to display large amounts of text. Underlying UITextView is a powerful layout engine called Text Kit. If you need to customize the layout process or you need to intervene in that behavior, you can use Text Kit. For smaller amounts of text and special needs requiring custom solutions, you can use alternative, lower-level technologies, as described in Lower Level Text-Handling Technologies.";
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSParagraphStyleAttributeName: paragraphStyle}];
    [attributedText addAttributes:@{MPITextLinkAttributeName: [MPITextLink new],
                                    NSForegroundColorAttributeName: [UIColor colorWithRed:0.093 green:0.492 blue:1.000 alpha:1.000],}
                            range:[text rangeOfString:@"Text-Handling"]];
    MPITextSelectionLabel *textView = [MPITextSelectionLabel new];
    textView.selectable = YES;
    textView.numberOfLines = 0;
    textView.textVerticalAlignment = MPITextVerticalAlignmentTop;
    textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    textView.attributedText = attributedText;
    textView.tintColor = [UIColor redColor];
    textView.selectedRange = [text rangeOfString:@"Text-Handling"];
    textView.delegate = self;
    [self.view addSubview:textView];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [textView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [textView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - MPILabelDelegate

- (void)labelWillBeginSelection:(MPILabel *)label selectedRange:(NSRangePointer)selectedRange {
    // You can change the selectedRange if you need.
//    *selectedRange = NSMakeRange(0, textView.attributedText.length);
}
 
- (NSArray<__kindof UIMenuItem *> *)menuItemsForLabel:(MPILabel *)label {
    UIMenuItem *helloItem = [[UIMenuItem alloc] initWithTitle:@"Hello" action:@selector(hello:)];
    return @[helloItem];
}
    
/** Menu
 - (BOOL)menuVisibleForLabel:(MPILabel *)label {
 
 }
 
 - (void)label:(MPILabel *)label showMenuWithMenuItems:(NSArray<UIMenuItem *> *)menuItems targetRect:(CGRect)targetRect {
 
 }

 - (void)labelHideMenu:(MPILabel *)label {
 
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
