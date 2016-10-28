//
//  DJIIntelligentFlightAssistant.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIIntelligentFlightAssistant;
@class DJIVisionDetectionState;

/**
 *
 *  This protocol provides a delegate method to update the Intelligent Flight
 *  Assistant current state.
 *
 */
@protocol DJIIntelligentFlightAssistantDelegate <NSObject>

@optional

/**
 *  Callback function that updates the vision detection state. The frequency of
 *  this method is 10Hz.
 */
- (void)intelligentFlightAssistant:(DJIIntelligentFlightAssistant *_Nonnull)assistant
     didUpdateVisionDetectionState:(DJIVisionDetectionState *_Nonnull)state;

@end

/**
 *  This class contains components of the Intelligent Flight Assistant and
 *  provides methods to change the settings of Intelligent Flight Assistant.
 */
@interface DJIIntelligentFlightAssistant : NSObject

/**
 *  Intelligent flight assistant delegate.
 */
@property(nonatomic, weak) id<DJIIntelligentFlightAssistantDelegate> delegate;

/**
 *  Set collision avoidance enabled. When collision avoidance is enabled, the
 *  aircraft will stop and try to go around an obstacle when detected.
 */
- (void)setCollisionAvoidanceEnabled:(BOOL)enable
                      withCompletion:(DJICompletionBlock)completion;

/**
 *  Get collision avoidance enabled.
 */
- (void)getCollisionAvoidanceEnabledWithCompletion:(void (^_Nonnull)(BOOL enable, NSError *_Nullable error))completion;

/**
 *  Set vision positioning enabled. Vision positioning is used to augment GPS to
 *  improve location accuracy when hovering and improve velocity calculation
 *  when flying.
 */
- (void)setVisionPositioningEnabled:(BOOL)enable
                     withCompletion:(DJICompletionBlock)completion;

/**
 *  Get vision position enable.
 */
- (void)getVisionPositioningEnabledWithCompletion:(void (^_Nonnull)(BOOL enable, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
