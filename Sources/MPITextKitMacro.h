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

#endif /* MPITextKitMacro_h */
