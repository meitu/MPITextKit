//
//  MPITextInteractiveGestureRecognizer.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Type of result of the gesture in state UIGestureRecognizerStateRecognized. */
typedef NS_ENUM(NSInteger, MPITextInteractiveGestureRecognizerResult) {
    MPITextInteractiveGestureRecognizerResultUnknown,
    MPITextInteractiveGestureRecognizerResultTap,
    MPITextInteractiveGestureRecognizerResultLongPress,
    MPITextInteractiveGestureRecognizerResultFailed,
    MPITextInteractiveGestureRecognizerResultCancelled
};

/** 
 A discreet gesture recognizer.
 */
@interface MPITextInteractiveGestureRecognizer : UIGestureRecognizer

/** The minimum period fingers must press on the view for the gesture to be recognized as a long press (default = 0.5s). */
@property (nonatomic) CFTimeInterval minimumPressDuration;
/** The maximum movement of the fingers on the view before the gesture gets recognized as failed (default = 10 points). */
@property (nonatomic) CGFloat allowableMovement;

/** Result code of the gesture when the gesture has been recognized (state is UIGestureRecognizerStateRecognized). */
@property (nonatomic, readonly) MPITextInteractiveGestureRecognizerResult result;

@end
