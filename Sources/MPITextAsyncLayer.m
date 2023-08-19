//
//  MPITextAsyncLayer.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextAsyncLayer.h"
#import "MPITextSentinel.h"
#import <libkern/OSAtomic.h>
#import "MPITextGeometryHelpers.h"

/// Global display queue, used for content rendering.
static dispatch_queue_t MPITextAsyncLayerGetDisplayQueue(void) {
#define MAX_QUEUE_COUNT 8
    static int32_t queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int32_t)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.mpitextkit.text.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.mpitextkit.text.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

static dispatch_queue_t MPITextAsyncLayerGetReleaseQueue(void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@implementation MPITextAsyncLayerDisplayTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displaysAsynchronously = YES;
    }
    return self;
}

@end


@implementation MPITextAsyncLayer {
    MPITextSentinel *_sentinel;
}

#pragma mark - Override

- (instancetype)init {
    self = [super init];
    self.contentsScale = MPITextScreenScale();
    _sentinel = [MPITextSentinel new];
    return self;
}

- (void)dealloc {
    [_sentinel increase];
}

- (void)setNeedsDisplay {
    [self _cancelAsyncDisplay];
    [super setNeedsDisplay];
}

- (void)display {
    super.contents = super.contents;
    [self _display];
}

#pragma mark - Private

- (void)_display {
    __strong id<MPITextAsyncLayerDelegate> delegate = (id)self.delegate;
    MPITextAsyncLayerDisplayTask *task = [delegate newAsyncDisplayTask];
    BOOL async = task.displaysAsynchronously;
    
    if (!task.display) {
        if (task.willDisplay) task.willDisplay(self);
        self.contents = nil;
        if (task.didDisplay) task.didDisplay(self, YES);
        return;
    }
    
    BOOL opaque = self.opaque;
    CGFloat scale = self.contentsScale;
    CGSize size = self.bounds.size;
    
    if (size.width < MPITextOnePixel() || size.height < MPITextOnePixel()) {
        if (task.willDisplay) task.willDisplay(self);
        CGImageRef image = (__bridge_retained CGImageRef)(self.contents);
        self.contents = nil;
        if (image) {
            dispatch_async(MPITextAsyncLayerGetReleaseQueue(), ^{
                CFRelease(image);
            });
        }
        if (task.didDisplay) task.didDisplay(self, YES);
        return;
    }
    
    if (async) {
        if (task.willDisplay) task.willDisplay(self);
        MPITextSentinel *sentinel = _sentinel;
        int32_t value = sentinel.value;
        BOOL (^isCancelled)(void) = ^BOOL(void) {
            return value != sentinel.value;
        };
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
        
        dispatch_async(MPITextAsyncLayerGetDisplayQueue(), ^{
            if (isCancelled()) {
                CGColorRelease(backgroundColor);
                return;
            }
            UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
            format.opaque = opaque;
            format.scale = scale;
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
            UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
                CGContextRef context = rendererContext.CGContext;
                if (opaque && context) {
                    CGContextSaveGState(context); {
                        if (!backgroundColor) {
                            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                        } else {
                            CGContextSetFillColorWithColor(context, backgroundColor);
                        }
                        CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                        CGContextFillPath(context);
                    } CGContextRestoreGState(context);
                }
                task.display(context, size, isCancelled);
            }];
            CGColorRelease(backgroundColor);
            if (isCancelled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancelled()) {
                    if (task.didDisplay) task.didDisplay(self, NO);
                } else {
                    self.contents = (__bridge id)(image.CGImage);
                    if (task.didDisplay) task.didDisplay(self, YES);
                }
            });
        });
    } else {
        [_sentinel increase];
        if (task.willDisplay) task.willDisplay(self);
        UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
        format.opaque = opaque;
        format.scale = scale;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            CGContextRef context = rendererContext.CGContext;
            if (opaque && context) {
                CGContextSaveGState(context); {
                    if (!self.backgroundColor) {
                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    } else {
                        CGContextSetFillColorWithColor(context, self.backgroundColor);
                    }
                    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
                    CGContextFillPath(context);
                } CGContextRestoreGState(context);
            }
            task.display(context, size, ^{return NO;});
        }];
        self.contents = (__bridge id)(image.CGImage);
        if (task.didDisplay) task.didDisplay(self, YES);
    }
}

- (void)_cancelAsyncDisplay {
    [_sentinel increase];
}

@end

