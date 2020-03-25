//
//  MPITextKitContext.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<MPITextKit/MPITextKit.h>)
#import <MPITextKit/MPITextLayoutManager.h>
#else
#import "MPITextLayoutManager.h"
#endif

/**
 A threadsafe container for the TextKit components that ASTextKit uses to lay out and truncate its text.
 
 This container is the sole owner and manager of the TextKit classes.  This is an important model because of major
 thread safety issues inside vanilla TextKit.  It provides a central locking location for accessing TextKit methods.
 */
@interface MPITextKitContext : NSObject

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                    maximumNumberOfLines:(NSUInteger)maximumNumberOfLines
                          exclusionPaths:(NSArray *)exclusionPaths
                         constrainedSize:(CGSize)constrainedSize;

/**
 All operations on TextKit values MUST occur within this locked context.  Simultaneous access (even non-mutative) to
 TextKit components may cause crashes.
 
 The block provided MUST not call out to client code from within its scope or it is possible for this to cause deadlocks
 in your application.  Use with EXTREME care.
 
 Callers MUST NOT keep a ref to these internal objects and use them later.  This WILL cause crashes in your application.
 */
- (void)performBlockWithLockedTextKitComponents:(void (^)(MPITextLayoutManager *layoutManager,
                                                          NSTextStorage *textStorage,
                                                          NSTextContainer *textContainer))block;

@end
