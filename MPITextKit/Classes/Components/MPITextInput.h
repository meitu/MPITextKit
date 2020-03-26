//
//  MPITextInput.h
//  MPITextKit
//
//  Created by Tpphha on 2020/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPITextSelectionRect : UITextSelectionRect

@property (nonatomic) CGRect rect;
@property (nonatomic) NSWritingDirection writingDirection;
@property (nonatomic) BOOL containsStart;
@property (nonatomic) BOOL containsEnd;
@property (nonatomic) BOOL isVertical;

@end

NS_ASSUME_NONNULL_END
