//
//  MPIExampleViewController.m
//  MPITextKit
//
//  Created by tpphha on 03/31/2019.
//  Copyright (c) 2019 美图网. All rights reserved.
//

#import "MPIExampleViewController.h"
#import "MPITextKit_Example-Swift.h"

@interface MPIExampleViewController ()

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *classNames;

@end

@implementation MPIExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"✎       MPITextKit Demo       ✎";
    self.titles = @[].mutableCopy;
    self.classNames = @[].mutableCopy;
    [self addCell:@"Text Attributes" class:@"MPITextAttributesViewController"];
    [self addCell:@"Text Attachment" class:@"MPITextAttachmentViewController"];
    [self addCell:@"Text Truncating" class:@"MPITextTruncatingViewController"];
    [self addCell:@"Async Display" class:@"MPITextAsyncDisplayViewController"];
    [self addCell:@"Exclusion Path" class:@"MPITextExclusionPathsViewController"];
    [self addCell:@"Custom Attribute" class:@"MPITextCustomAttributeViewController"];
    [self addCell:@"Swift Example" class:NSStringFromClass(MPITextSwfitExampleViewController.class)];
    [self addCell:@"Text Selection" class:@"MPITextSelectionViewController"];
    [self addCell:@"Size Calculation" class:@"MPITextSizeCalculationViewController"];
    [self.tableView reloadData];
}

- (void)addCell:(NSString *)title class:(NSString *)className {
    [self.titles addObject:title];
    [self.classNames addObject:className];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class aClass = NSClassFromString(self.classNames[indexPath.item]);
    UIViewController *viewController = [aClass new];
    viewController.title = self.titles[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
