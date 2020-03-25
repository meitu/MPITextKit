//
//  MPITextDebugOption.h
//  MeituMV
//
//  Created by Tpphha on 2019/3/24.
//  Copyright © 2019 美图网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MPITextDebugOption;

/**
 The MPITextDebugTarget protocol defines the method a debug target should implement.
 A debug target can be add to the global container to receive the shared debug
 option changed notification.
 */
@protocol MPITextDebugTarget <NSObject>

@required
/**
 When the shared debug option changed, this method would be called on main thread.
 It should return as quickly as possible. The option's property should not be changed
 in this method.
 
 @param option  The shared debug option.
 */
- (void)setDebugOption:(nullable MPITextDebugOption *)option;

@end


/**
 The debug option for MPIText.
 */
@interface MPITextDebugOption : NSObject <NSCopying>
@property (nullable, nonatomic) UIColor *baselineColor;      ///< baseline color
@property (nullable, nonatomic) UIColor *lineFragmentBorderColor;  ///< LineFragment bounds border color
@property (nullable, nonatomic) UIColor *lineFragmentFillColor;    ///< LineFragment bounds fill color
@property (nullable, nonatomic) UIColor *lineFragmentUsedBorderColor;  ///< LineFragment used bounds border color
@property (nullable, nonatomic) UIColor *lineFragmentUsedFillColor;    ///< LineFragment used bounds fill color
@property (nullable, nonatomic) UIColor *glyphBorderColor; ///< Glyph bounds border color
@property (nullable, nonatomic) UIColor *glyphFillColor;   ///< Glyph bounds fill color

- (BOOL)needsDrawDebug; ///< `YES`: at least one debug color is visible. `NO`: all debug color is invisible/nil.
- (void)clear; ///< Set all debug color to nil.

/**
 Add a debug target.
 
 @discussion When `setSharedDebugOption:` is called, all added debug target will
 receive `setDebugOption:` in main thread. It maintains an unsafe_unretained
 reference to this target. The target must to removed before dealloc.
 
 @param target A debug target.
 */
+ (void)addDebugTarget:(id<MPITextDebugTarget>)target;

/**
 Remove a debug target which is added by `addDebugTarget:`.
 
 @param target A debug target.
 */
+ (void)removeDebugTarget:(id<MPITextDebugTarget>)target;

/**
 Returns the shared debug option.
 
 @return The shared debug option, default is nil.
 */
+ (nullable MPITextDebugOption *)sharedDebugOption;

/**
 Set a debug option as shared debug option.
 This method must be called on main thread.
 
 @discussion When call this method, the new option will set to all debug target
 which is added by `addDebugTarget:`.
 
 @param option  A new debug option (nil is valid).
 */
+ (void)setSharedDebugOption:(nullable MPITextDebugOption *)option;

@end

NS_ASSUME_NONNULL_END
