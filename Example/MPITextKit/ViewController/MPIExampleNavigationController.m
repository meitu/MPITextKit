//
//  MPIExampleNavigationController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPIExampleNavigationController.h"
#import "YYFPSLabel.h"

@interface MPIExampleNavigationController ()

@end

@implementation MPIExampleNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    YYFPSLabel *fpsLabel = [YYFPSLabel new];
    [fpsLabel sizeToFit];
    [self.view addSubview:fpsLabel];
    
    fpsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [fpsLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:64].active = YES;
    [fpsLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15].active = YES;
    
    self.fpsLabel = fpsLabel;
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
