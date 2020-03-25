//
//  MPITextDebugOption.m
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import "MPITextDebugOption.h"
#import <pthread.h>

static pthread_mutex_t _sharedDebugLock;
static CFMutableSetRef _sharedDebugTargets = nil;
static MPITextDebugOption *_sharedDebugOption = nil;

static const void* _mpi_sharedDebugSetRetain(CFAllocatorRef allocator, const void *value) {
    return value;
}

static void _mpi_sharedDebugSetRelease(CFAllocatorRef allocator, const void *value) {
}

void _mpi_sharedDebugSetFunction(const void *value, void *context) {
    id<MPITextDebugTarget> target = (__bridge id<MPITextDebugTarget>)(value);
    [target setDebugOption:_sharedDebugOption];
}

static void _initSharedDebug() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_sharedDebugLock, NULL);
        CFSetCallBacks callbacks = kCFTypeSetCallBacks;
        callbacks.retain = _mpi_sharedDebugSetRetain;
        callbacks.release = _mpi_sharedDebugSetRelease;
        _sharedDebugTargets = CFSetCreateMutable(CFAllocatorGetDefault(), 0, &callbacks);
    });
}

static void _setSharedDebugOption(MPITextDebugOption *option) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    _sharedDebugOption = option.copy;
    CFSetApplyFunction(_sharedDebugTargets, _mpi_sharedDebugSetFunction, NULL);
    pthread_mutex_unlock(&_sharedDebugLock);
}

static MPITextDebugOption *_getSharedDebugOption() {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    MPITextDebugOption *op = _sharedDebugOption;
    pthread_mutex_unlock(&_sharedDebugLock);
    return op;
}

static void _addDebugTarget(id<MPITextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetAddValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}

static void _removeDebugTarget(id<MPITextDebugTarget> target) {
    _initSharedDebug();
    pthread_mutex_lock(&_sharedDebugLock);
    CFSetRemoveValue(_sharedDebugTargets, (__bridge const void *)(target));
    pthread_mutex_unlock(&_sharedDebugLock);
}

@implementation MPITextDebugOption

- (id)copyWithZone:(NSZone *)zone {
    MPITextDebugOption *op = [[self.class allocWithZone:zone] init];
    op.baselineColor = self.baselineColor;
    op.lineFragmentFillColor = self.lineFragmentFillColor;
    op.lineFragmentBorderColor = self.lineFragmentBorderColor;
    op.lineFragmentUsedFillColor = self.lineFragmentUsedFillColor;
    op.lineFragmentUsedBorderColor = self.lineFragmentUsedBorderColor;
    op.glyphFillColor = self.glyphFillColor;
    op.glyphBorderColor = self.glyphBorderColor;
    return op;
}

- (BOOL)needsDrawDebug {
    if (self.baselineColor ||
        self.lineFragmentFillColor ||
        self.lineFragmentBorderColor ||
        self.lineFragmentUsedFillColor ||
        self.lineFragmentUsedBorderColor ||
        self.glyphFillColor ||
        self.glyphBorderColor) return YES;
    return NO;
}

- (void)clear {
    self.baselineColor = nil;
    self.lineFragmentFillColor = nil;
    self.lineFragmentBorderColor = nil;
    self.lineFragmentUsedFillColor = nil;
    self.lineFragmentUsedBorderColor = nil;
    self.glyphFillColor = nil;
    self.glyphBorderColor = nil;
}

+ (void)addDebugTarget:(id<MPITextDebugTarget>)target {
    if (target) _addDebugTarget(target);
}

+ (void)removeDebugTarget:(id<MPITextDebugTarget>)target {
    if (target) _removeDebugTarget(target);
}

+ (MPITextDebugOption *)sharedDebugOption {
    return _getSharedDebugOption();
}

+ (void)setSharedDebugOption:(MPITextDebugOption *)option {
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    _setSharedDebugOption(option);
}

@end
