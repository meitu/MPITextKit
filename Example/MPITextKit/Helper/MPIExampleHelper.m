//
//  MPIExampleHelper.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPIExampleHelper.h"
#import <MPITextKit/MPITextKit.h>

static BOOL DebugEnabled = NO;

@implementation MPIExampleHelper

+ (void)addDebugOptionToViewController:(UIViewController *)viewController {
    UISwitch *switcher = [UISwitch new];
    [switcher.layer setValue:@(0.8) forKeyPath:@"transform.scale"];
    
    [switcher setOn:DebugEnabled];
    [switcher addTarget:self action:@selector(toggleAction:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:switcher];
    viewController.navigationItem.rightBarButtonItem = item;
}

+ (void)setDebug:(BOOL)debug {
    MPITextDebugOption *debugOptions = [MPITextDebugOption new];
    if (debug) {
        debugOptions.baselineColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        debugOptions.lineFragmentBorderColor = [[UIColor redColor] colorWithAlphaComponent:0.200];
        debugOptions.lineFragmentUsedBorderColor = [UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:0.200];
        debugOptions.glyphBorderColor = [UIColor colorWithRed:1.000 green:0.524 blue:0.000 alpha:0.200];
    } else {
        [debugOptions clear];
    }
    [MPITextDebugOption setSharedDebugOption:debugOptions];
    DebugEnabled = debug;
}

+ (BOOL)isDebug {
    return DebugEnabled;
}

+ (void)toggleAction:(UISwitch *)switcher {
    [self setDebug:switcher.isOn];
}

@end
