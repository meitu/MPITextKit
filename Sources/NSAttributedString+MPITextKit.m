//
//  NSAttributedString+MPITextKit.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "NSAttributedString+MPITextKit.h"
#import "MPITextAttributes.h"

@implementation NSAttributedString (MPITextKit)

- (NSRange)mpi_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (NSString *)mpi_plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound || range.length == 0) {
        return nil;
    }
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) {
        return result;
    }
    NSString *string = self.string;
    [self enumerateAttribute:MPITextBackedStringAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        MPITextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            NSRange startRange = [string rangeOfComposedCharacterSequenceAtIndex:range.location];
            NSRange endRange = [string rangeOfComposedCharacterSequenceAtIndex:NSMaxRange(range) - 1];
            [result appendString:[string substringWithRange:NSMakeRange(startRange.location, NSMaxRange(endRange) - startRange.location)]];
        }
    }];
    return result;
}

@end
