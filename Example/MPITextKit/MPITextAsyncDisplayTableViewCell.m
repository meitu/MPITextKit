//
//  MPITextAsyncDisplayTableViewCell.m
//  MPITextKit_Example
//
//  Created by Tpphha on 2019/3/31.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAsyncDisplayTableViewCell.h"
#import <MPITextkit/MPITextKit.h>

#import "UIView+MPIExample.h"

@interface MPITextAsyncDisplayTableViewCell ()

@property (nonatomic, strong) UILabel *uiLabel;
@property (nonatomic, strong) MPILabel *mpiLabel;

@end

@implementation MPITextAsyncDisplayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _uiLabel = [UILabel new];
    _uiLabel.font = [UIFont systemFontOfSize:8];
    _uiLabel.numberOfLines = 3;
    _uiLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width;
    
    _mpiLabel = [MPILabel new];
    _mpiLabel.font = _uiLabel.font;
    _mpiLabel.numberOfLines = _uiLabel.numberOfLines;
    _mpiLabel.displaysAsynchronously = YES;
    _mpiLabel.lineBreakMode = _uiLabel.lineBreakMode;
    _mpiLabel.preferredMaxLayoutWidth = _uiLabel.preferredMaxLayoutWidth;
    
    [self.contentView addSubview:_mpiLabel];
    [self.contentView addSubview:_uiLabel];
    
    NSArray<UIView *> *views = @[_uiLabel, _mpiLabel];
    [views enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.translatesAutoresizingMaskIntoConstraints = NO;
        [obj.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor].active = YES;
        [obj.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor].active = YES;
        [obj.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [obj.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    }];
    
    return self;
}

- (void)setText:(id)text async:(BOOL)async {
    _mpiLabel.hidden = !async;
    _uiLabel.hidden = async;
    if (async) {
        _mpiLabel.textRenderer = text;
    } else {
        _uiLabel.attributedText = text;
    }
}

@end
