//
//  MPITextTruncatingTableViewCell.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextTruncatingTableViewCell.h"

@implementation MPITextTruncatingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *text = @"The UIKit framework includes several classes whose purpose is to display text in an app’s user interface: UITextView, UITextField, and UILabel, as described in Displaying Text Content in iOS. Text views, created from the UITextView class, are meant to display large amounts of text. Underlying UITextView is a powerful layout engine called Text Kit. If you need to customize the layout process or you need to intervene in that behavior, you can use Text Kit. For smaller amounts of text and special needs requiring custom solutions, you can use alternative, lower-level technologies, as described in Lower Level Text-Handling Technologies.";
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 5;
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSParagraphStyleAttributeName: paragraphStyle}];
        _mpiLabel = [MPILabel new];
        _mpiLabel.userInteractionEnabled = YES;
        _mpiLabel.numberOfLines = 5;
        _mpiLabel.truncationAttributedToken = MPITextDefaultTruncationAttributedToken();
        _mpiLabel.attributedText = attributedText;
        _mpiLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _mpiLabel.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
        [self.contentView addSubview:_mpiLabel];
        NSArray<NSNumber *> *attributes = @[@(NSLayoutAttributeTop), @(NSLayoutAttributeLeft), @(NSLayoutAttributeBottom), @(NSLayoutAttributeRight)];
        NSMutableArray *constraints = [NSMutableArray new];
        [attributes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLayoutAttribute attribute = obj.integerValue;
            NSLayoutConstraint *constraint =
            [NSLayoutConstraint constraintWithItem:_mpiLabel attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:attribute multiplier:1.0 constant:0];
            [constraints addObject:constraint];
        }];
        
        [self.contentView addConstraints:constraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
