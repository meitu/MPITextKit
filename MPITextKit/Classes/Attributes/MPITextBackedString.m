//
//  MPITextBackedString.m
//  MeituMV
//
//  Created by Tpphha on 2018/11/9.
//  Copyright © 2018 美图网. All rights reserved.
//

#import "MPITextBackedString.h"

@implementation MPITextBackedString

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _string = string.copy;
    }
    return self;
}

+ (instancetype)stringWithString:(NSString *)string {
    return [[self alloc] initWithString:string];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) one = [[self.class allocWithZone:zone] init];
    one.string = self.string;
    return one;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.string forKey:@"string"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _string = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (NSUInteger)hash {
    return [_string hash];
}

- (BOOL)isEqual:(MPITextBackedString *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    return [_string isEqualToString:object.string];
}


@end
