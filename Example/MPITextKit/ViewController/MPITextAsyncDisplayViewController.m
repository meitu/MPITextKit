//
//  MPITextAsyncDisplayViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAsyncDisplayViewController.h"
#import "MPIExampleNavigationController.h"
#import "MPITextAsyncDisplayTableViewCell.h"
#import "MPIExampleHelper.h"
#import <MPITextKit/MPITextKit.h>

@interface MPITextAsyncDisplayViewController ()

@property (nonatomic, copy) NSArray<NSAttributedString *> *strings;
@property (nonatomic, copy) NSArray<MPITextRenderer *> *textRenderers;
@property (nonatomic, assign) BOOL async;

@property (nonatomic, strong) UIView *toolbar;

@end

@implementation MPITextAsyncDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 34;
    [self.tableView registerClass:[MPITextAsyncDisplayTableViewCell class] forCellReuseIdentifier:@"id"];
    
    NSMutableArray *strings = [NSMutableArray new];
    NSMutableArray *textRenderers = [NSMutableArray new];
    for (int i = 0; i < 300; i++) {
        NSString *str = [NSString stringWithFormat:@"%d Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺ 😀😖😐😣😡🚖🚌🚋🎊💖💗💛💙🏨🏦🏫 Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺",i];
        
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc] initWithString:str attributes:@{
                                                                           NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                           NSStrokeColorAttributeName: [UIColor redColor],
                                                                           NSStrokeWidthAttributeName: @(-3),
                                                                           }];
        
        [strings addObject:text];
        
        MPITextRenderAttributesBuilder *attributesBuiler = [[MPITextRenderAttributesBuilder alloc] init];
        attributesBuiler.attributedText = text;
        attributesBuiler.lineBreakMode = NSLineBreakByTruncatingTail;
        attributesBuiler.maximumNumberOfLines = 3;
        attributesBuiler.truncationAttributedText = MPITextDefaultTruncationAttributedToken();
        MPITextRenderer *renderer = [[MPITextRenderer alloc] initWithRenderAttributes:[attributesBuiler build] constrainedSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGFLOAT_MAX)];
        [textRenderers addObject:renderer];
    }
    self.strings = strings;
    self.textRenderers = textRenderers;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addToolbar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeToolbar];
}

- (void)addToolbar {
    MPIExampleNavigationController *navigationController = (MPIExampleNavigationController *)self.navigationController;
    UIView *containerView = navigationController.view;
    UIVisualEffectView *toolbar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [containerView insertSubview:toolbar belowSubview:navigationController.fpsLabel];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolbar.topAnchor constraintEqualToAnchor:containerView.safeAreaLayoutGuide.topAnchor
                                      constant:CGRectGetHeight(self.navigationController.navigationBar.frame)].active = YES;
    [toolbar.leftAnchor constraintEqualToAnchor:containerView.leftAnchor].active = YES;
    [toolbar.rightAnchor constraintEqualToAnchor:containerView.rightAnchor].active = YES;
    [toolbar.heightAnchor constraintEqualToConstant:44].active = YES;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"UILabel/MPILabel(Async): ";
    
    UISwitch *switcher = [[UISwitch alloc] init];
    [switcher.layer setValue:@(0.8) forKeyPath:@"transform.scale"];
    switcher.on = _async;
    [switcher sizeToFit];
    [switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, switcher]];
    stackView.spacing = 8;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    
    [toolbar.contentView addSubview:stackView];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView.leftAnchor constraintEqualToAnchor:toolbar.leftAnchor constant:8.f].active = YES;
    [stackView.centerYAnchor constraintEqualToAnchor:toolbar.centerYAnchor].active = YES;
    
    [self removeToolbar];
    self.toolbar = toolbar;
}

- (void)removeToolbar {
    [self.toolbar removeFromSuperview];
}

- (void)switchAction:(UISwitch *)switcher {
    _async = !_async;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _strings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPITextAsyncDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    if (_async) {
        [cell setText:_textRenderers[indexPath.row] async:_async];
    } else {
        [cell setText:_strings[indexPath.row] async:_async];
    }
    return cell;
}

@end
