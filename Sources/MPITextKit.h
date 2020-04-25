//
//  MPITextKit.h
//  MeituMV
//
//  Created by Tpphha on 2018/8/13.
//  Copyright © 2018年 美图网. All rights reserved.
//

#ifndef MPITextKit_h
#define MPITextKit_h

#if __has_include(<MPITextKit/MPITextKit.h>)
FOUNDATION_EXPORT double MPITextKitVersionNumber;
FOUNDATION_EXPORT const unsigned char MPITextKitVersionString[];
#import <MPITextKit/MPILabel.h>
#import <MPITextKit/MPITextParser.h>
#import <MPITextKit/MPITextDefaultsValueHelpers.h>
#import <MPITextKit/MPITextGeometryHelpers.h>
#import <MPITextKit/MPITextEqualityHelpers.h>
#import <MPITextKit/MPITextHashing.h>
#import <MPITextKit/NSAttributedString+MPITextKit.h>
#import <MPITextKit/NSMutableAttributedString+MPITextKit.h>
#import <MPITextKit/NSMutableParagraphStyle+MPITextKit.h>
#else
#import "MPILabel.h"
#import "MPITextParser.h"
#import "MPITextDefaultsValueHelpers.h"
#import "MPITextGeometryHelpers.h"
#import "MPITextEqualityHelpers.h"
#import "MPITextHashing.h"
#import "NSAttributedString+MPITextKit.h"
#import "NSMutableAttributedString+MPITextKit.h"
#import "NSMutableParagraphStyle+MPITextKit.h"
#endif

#endif /* MPITextKit_h */
