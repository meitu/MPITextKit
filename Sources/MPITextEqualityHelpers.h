//
//  MPITextEqualityHelpers.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#ifndef MPITextEqualityHelpers_h
#define MPITextEqualityHelpers_h

/**
 @abstract Correctly equates two objects, including cases where both objects are nil. The latter is a case where `isEqual:` fails.
 @param obj The first object in the comparison. Can be nil.
 @param otherObj The second object in the comparison. Can be nil.
 @result YES if the objects are equal, including cases where both object are nil.
 */
static inline BOOL MPITextObjectIsEqual(id<NSObject> obj, id<NSObject> otherObj)
{
    return obj == otherObj || [obj isEqual:otherObj];
}

#endif /* MPITextEqualityHelpers_h */
