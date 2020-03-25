//
//  MPITextAttributes.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextBackedString.h>
#import <MPITextKit/MPITextAttachment.h>
#import <MPITextKit/MPITextBackground.h>
#import <MPITextKit/MPITextLink.h>
#else
#import "MPITextBackedString.h"
#import "MPITextAttachment.h"
#import "MPITextBackground.h"
#import "MPITextLink.h"
#endif
