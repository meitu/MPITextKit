//
//  MPITextKitMacro.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#ifndef MPITextKitMacro_h
#define MPITextKitMacro_h

#ifndef MPITEXT_SWAP // swap two value
#define MPITEXT_SWAP(_a_, _b_)  do { __typeof__(_a_) _tmp_ = (_a_); (_a_) = (_b_); (_b_) = _tmp_; } while (0)
#endif

#if defined (__cplusplus) && defined (__GNUC__)
# define MPITextKit_NOTHROW __attribute__ ((nothrow))
#else
# define MPITextKit_NOTHROW
#endif

// This MUST always execute, even when assertions are disabled. Otherwise all lock operations become no-ops!
// (To be explicit, do not turn this into an NSAssert, assert(), or any other kind of statement where the
// evaluation of x_ can be compiled out.)
#define MPITextKit_POSIX_ASSERT_NOERR(x_) ({ \
__unused int res = (x_); \
NSCAssert(res == 0, @"Expected %s to return 0, got %d instead. Error: %s", #x_, res, strerror(res)); \
})

// Use __builtin_available if we're on Xcode >= 9, MPITextKit_AT_LEAST otherwise.
#if __has_builtin(__builtin_available)
#define MPITextKit_AVAILABLE_IOS(ver)               __builtin_available(iOS ver, *)
#define MPITextKit_AVAILABLE_TVOS(ver)              __builtin_available(tvOS ver, *)
#define MPITextKit_AVAILABLE_IOS_TVOS(ver1, ver2)   __builtin_available(iOS ver1, tvOS ver2, *)
#else
#define MPITextKit_AVAILABLE_IOS(ver)               (TARGET_OS_IOS && MPITextKit_AT_LEAST_IOS##ver)
#define MPITextKit_AVAILABLE_TVOS(ver)              (TARGET_OS_TV && MPITextKit_AT_LEAST_IOS##ver)
#define MPITextKit_AVAILABLE_IOS_TVOS(ver1, ver2)   (MPITextKit_AVAILABLE_IOS(ver1) || MPITextKit_AVAILABLE_TVOS(ver2))
#endif

#endif /* MPITextKitMacro_h */
