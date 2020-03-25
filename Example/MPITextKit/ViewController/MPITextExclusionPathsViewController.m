//
//  MPITextExclusionPathsViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/4/1.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextExclusionPathsViewController.h"
#import <MPITextKit/MPITextKit.h>

#import "MPIExampleHelper.h"

#import "UIView+MPIExample.h"

@interface MPITextExclusionPathsViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *dragView;
@property (nonatomic, strong) MPILabel *textView;
@property (nonatomic, assign) BOOL layoutFlag;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation MPITextExclusionPathsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    NSString *text = @"The UIKit framework includes several classes whose purpose is to display text in an app’s user interface: UITextView, UITextField, and UILabel, as described in Displaying Text Content in iOS. Text views, created from the UITextView class, are meant to display large amounts of text. Underlying UITextView is a powerful layout engine called Text Kit. If you need to customize the layout process or you need to intervene in that behavior, you can use Text Kit. For smaller amounts of text and special needs requiring custom solutions, you can use alternative, lower-level technologies, as described in Lower Level Text-Handling Technologies.\nText Kit is a set of classes and protocols in the UIKit framework providing high-quality typographical services that enable apps to store, lay out, and display text with all the characteristics of fine typesetting, such as kerning, ligatures, line breaking, and justification. Text Kit is built on top of Core Text, so it provides the same speed and power. UITextView is fully integrated with Text Kit; it provides editing and display capabilities that enable users to input text, specify formatting attributes, and view the results. The other Text Kit classes provide text storage and layout capabilities.";
    
    MPILabel *textView = [MPILabel new];
    textView.numberOfLines = 0;
    textView.textVerticalAlignment = MPITextVerticalAlignmentTop;
    textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textView.text = text;
    textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    textView.selectable = YES;
    [self.view addSubview:textView];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [textView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    [textView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [textView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    self.textView = textView;
    
    UIImage *image = [UIImage imageNamed:@"dribbble256_imageio"];
    image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:UIImageOrientationUp];
    
    self.dragView = [[UIImageView alloc] initWithImage:image];
    self.dragView.userInteractionEnabled = YES;
    self.dragView.clipsToBounds = YES;
    self.dragView.layer.cornerRadius = self.dragView.height / 2;
    [self.view addSubview:self.dragView];
    
    
    self.shapeLayer = [CAShapeLayer new];
    self.shapeLayer.borderColor = [UIColor blueColor].CGColor;
    self.shapeLayer.borderWidth = 1.0;
    self.shapeLayer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor;
    [self.view.layer addSublayer:self.shapeLayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [pan requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.layoutFlag) {
        self.layoutFlag = YES;
        [self updateDragViewLocation:self.textView.center];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan locationInView:self.view];
    [self updateDragViewLocation:p];
}

- (void)updateDragViewLocation:(CGPoint)location {
    self.dragView.center = location;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectOffset(self.dragView.frame, -self.textView.origin.x, -self.textView.origin.y)
                                                    cornerRadius:self.dragView.layer.cornerRadius];
    self.textView.exclusionPaths = @[path];
    self.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.dragView.frame
                                                      cornerRadius:self.dragView.layer.cornerRadius].CGPath;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    return CGRectContainsPoint(self.dragView.frame, location);
}

@end
