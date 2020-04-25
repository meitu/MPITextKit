//
//  MPITextThread.hpp
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <stdio.h>
#import <pthread.h>
#import <stdio.h>
#include <memory>
#import <assert.h>
#import <os/lock.h>
#import <stdbool.h>
#import <stdlib.h>

#import "MPITextKitMacro.h"

namespace MPITextKit {
    
    template<class T>
    class SharedLocker
    {
        std::shared_ptr<T> _l;
        
    public:
        SharedLocker (std::shared_ptr<T> const& l) MPITextKit_NOTHROW : _l (l) {
            NSCAssert(_l != nullptr, @"Expected it to be true.");
            _l->lock ();
        }
        
        ~SharedLocker () {
            _l->unlock ();
        }
        
        // non-copyable.
        SharedLocker(const SharedLocker<T>&) = delete;
        SharedLocker &operator=(const SharedLocker<T>&) = delete;
    };
    
    template<class T>
    class Locker
    {
        T &_l;
        
    public:
        Locker (T &l) MPITextKit_NOTHROW : _l (l) {
            _l.lock ();
        }
        
        ~Locker () {
            _l.unlock ();
        }
        
        // non-copyable.
        Locker(const Locker<T>&) = delete;
        Locker &operator=(const Locker<T>&) = delete;
    };
    
    template<class T>
    class Unlocker
    {
        T &_l;
    public:
        Unlocker (T &l) MPITextKit_NOTHROW : _l (l) { _l.unlock (); }
        ~Unlocker () {_l.lock ();}
        Unlocker(Unlocker<T>&) = delete;
        Unlocker &operator=(Unlocker<T>&) = delete;
    };
    
    // Silence unguarded availability warnings in here, because
    // perf is critical and we will check availability once
    // and not again.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    struct Mutex
    {
        /// Constructs a non-recursive mutex (the default).
        Mutex () : Mutex (false) {}
        
        ~Mutex () {
            MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_destroy (&_m));
        }
        
        Mutex (const Mutex&) = delete;
        Mutex &operator=(const Mutex&) = delete;
        
        void lock() {
            MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_lock(&_m));
        }
        
        void unlock () {
            MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_unlock(&_m));
        }
        
        pthread_mutex_t *mutex () { return &_m; }
        
    protected:
        explicit Mutex (bool recursive) {
            
            _recursive = recursive;
            
            if (!recursive) {
                MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_init (&_m, NULL));
            } else {
                // Fall back to recursive mutex.
                static pthread_mutexattr_t attr;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    MPITextKit_POSIX_ASSERT_NOERR(pthread_mutexattr_init (&attr));
                    MPITextKit_POSIX_ASSERT_NOERR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
                });
                MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_init(&_m, &attr));
            }
        }
        
    private:
        BOOL _recursive;
        union {
            os_unfair_lock _unfair;
            pthread_mutex_t _m;
        };
    };
#pragma clang diagnostic pop // ignored "-Wunguarded-availability"
    
    /**
     Obj-C doesn't allow you to pass parameters to C++ ivar constructors.
     Provide a convenience to change the default from non-recursive to recursive.
     
     But wait! Recursive mutexes are a bad idea. Think twice before using one:
     
     http://www.zaval.org/resources/library/butenhof1.html
     http://www.fieryrobot.com/blog/2008/10/14/recursive-locks-will-kill-you/
     */
    struct RecursiveMutex : Mutex
    {
        RecursiveMutex () : Mutex (true) {}
    };
    
    typedef Locker<Mutex> MutexLocker;
    typedef SharedLocker<Mutex> MutexSharedLocker;
    typedef Unlocker<Mutex> MutexUnlocker;
    
    /**
     If you are creating a static mutex, use StaticMutex. This avoids expensive constructor overhead at startup (or worse, ordering
     issues between different static objects). It also avoids running a destructor on app exit time (needless expense).
     
     Note that you can, but should not, use StaticMutex for non-static objects. It will leak its mutex on destruction,
     so avoid that!
     */
    struct StaticMutex
    {
        StaticMutex () : _m (PTHREAD_MUTEX_INITIALIZER) {}
        
        // non-copyable.
        StaticMutex(const StaticMutex&) = delete;
        StaticMutex &operator=(const StaticMutex&) = delete;
        
        void lock () {
            MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_lock (this->mutex()));
        }
        
        void unlock () {
            MPITextKit_POSIX_ASSERT_NOERR(pthread_mutex_unlock (this->mutex()));
        }
        
        pthread_mutex_t *mutex () { return &_m; }
        
    private:
        pthread_mutex_t _m;
    };
    
    typedef Locker<StaticMutex> StaticMutexLocker;
    typedef Unlocker<StaticMutex> StaticMutexUnlocker;
}

