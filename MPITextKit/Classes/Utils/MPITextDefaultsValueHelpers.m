//
//  MPITextDefaultsValueHelpers.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextDefaultsValueHelpers.h"
#import "MPITextAttributes.h"

NSDictionary *MPITextDefaultLinkTextAttributes() {
    return @{
             NSForegroundColorAttributeName: [UIColor colorWithRed:69 / 255.f green:110 / 255.f blue:192 / 255.f alpha:1.f]
             };
}

NSDictionary *MPITextDefaultHighlightedLinkTextAttributes() {
    MPITextBackground *background = [MPITextBackground backgroundWithFillColor:UIColor.lightGrayColor cornerRadius:3.0];
    return  @{
              MPITextBackgroundAttributeName: background,
              };
}

NSCharacterSet *MPITextDefaultAvoidTruncationCharacterSet() {
    static NSCharacterSet *truncationCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *mutableCharacterSet = [[NSMutableCharacterSet alloc] init];
        [mutableCharacterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
        // AsyncDisplayKit behavior。
        // [mutableCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // [mutableCharacterSet addCharactersInString:@".,!?:;"];
        truncationCharacterSet = mutableCharacterSet;
    });
    return truncationCharacterSet;
}

NSAttributedString *MPITextDefaultTruncationAttributedToken() {
    static NSAttributedString *defaultTruncationAttributedToken;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTruncationAttributedToken = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\u2026", @"Default truncation string")];
    });
    return defaultTruncationAttributedToken;
}

NSString *MPITextDefaultTruncationToken() {
    static NSString *defaultTruncationToken;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTruncationToken = MPITextDefaultTruncationAttributedToken().string;
    });
    return defaultTruncationToken;
}

CGFloat MPITextCoreTextDefaultFontSize() {
    return 12.0;
}
