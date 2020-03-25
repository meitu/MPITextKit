//
//  MPITextTruncatingViewController.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextTruncatingViewController.h"
#import "MPITextTruncatingTableViewCell.h"

#import "MPIExampleHelper.h"

@interface MPITextTruncatingViewController () <MPILabelDelegate>

@property (nonatomic, strong) NSMutableArray<NSAttributedString *> *attributedTruncationMessages;

@end

@implementation MPITextTruncatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MPIExampleHelper addDebugOptionToViewController:self];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView registerClass:MPITextTruncatingTableViewCell.class forCellReuseIdentifier:@"id"];
    _attributedTruncationMessages = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < 100; i++) {
        NSString *tuncationMessage = [NSString stringWithFormat:@"more%@", @(i)];
        NSAttributedString *attributedTuncationMessage =
        [[NSAttributedString alloc] initWithString:tuncationMessage attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.000 green:0.449 blue:1.000 alpha:1.000], MPITextLinkAttributeName: [MPITextLink new]}];
        [_attributedTruncationMessages addObject:attributedTuncationMessage];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attributedTruncationMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPITextTruncatingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    cell.mpiLabel.additionalTruncationAttributedMessage = self.attributedTruncationMessages[indexPath.row];
    cell.mpiLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame);
    cell.mpiLabel.delegate = self;
    return cell;
}

#pragma mark - MPILabelDelegate

- (void)label:(MPILabel *)label didInteractWithLink:(MPITextLink *)link forAttributedText:(NSAttributedString *)attributedText inRange:(NSRange)characterRange interaction:(MPITextItemInteraction)interaction {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[label.superview convertPoint:label.center toView:self.tableView]];
    if (indexPath) {
        self.title = [NSString stringWithFormat:@"Cell %@ %@", @(indexPath.row), interaction == MPITextItemInteractionTap ? @"Tapped" : @"Long pressed"];
    }
}

@end
