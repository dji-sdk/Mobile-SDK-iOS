//
//  DJICameraSSDState.h
//  DJISDK
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJICameraSettingsDef.h>

/**
 *  Solid State Drive (SSD) State
 */
typedef NS_ENUM (NSUInteger, DJICameraSSDOperationState) {
    /**
     *  SSD is idle.
     */
    DJICameraSSDOperationStateIdle,
    /**
     *  SSD is Saving.
     */
    DJICameraSSDOperationStateSaving,
    /**
     *  SSD is formatting.
     */
    DJICameraSSDOperationStateFormatting,
    /**
     *  SSD is Initializing.
     */
    DJICameraSSDOperationStateInitializing,
    /**
     *  SSD validation error.
     */
    DJICameraSSDOperationStateError,
    /**
     *  SSD is full.
     */
    DJICameraSSDOperationStateFull,
    /**
     *  SSD state is unknown. This happens in the first 2 seconds after turning the camera power on as during this time the camera cannot check the state of the SSD.
     */
    DJICameraSSDOperationStateUnknown = 0xFF,
};

/**
 *  Solid State Drive (SSD) Capacity
 */
typedef NS_ENUM (NSUInteger, DJICameraSSDCapacity) {
    /**
     *  SSD capacity is 256G.
     */
    DJICameraSSDCapacity256G,
    /**
     *  SSD capacity is 512G.
     */
    DJICameraSSDCapacity512G,
    /**
     *  SSD capacity is 1T.
     */
    DJICameraSSDCapacity1T,
    /**
     *  SSD capacity is unknown.
     */
    DJICameraSSDCapacityUnknown = 0xFF,
};


/**
 *  This class contains the information about camera's Solid State Drive (SSD) information, including state, whether it is connected, its capacity, video size and rate, etc.
 *
 *  Supported only by the X5R camera.
 */
@interface DJICameraSSDState : NSObject

/**
 *  SSD state information for currently executing operations.
 */
@property (nonatomic, readonly) DJICameraSSDOperationState operationState;

/**
 *  YES if the SSD is connected. When `isConnected` is `NO`, the values for other properties in `DJICameraSSDState` are undefined.
 */
@property (nonatomic, readonly) BOOL isConnected;

/**
 *  SSD's total capacity.
 */
@property (nonatomic, readonly) DJICameraSSDCapacity totalSpace;

/**
 *  SSD's remaining time in seconds, based on the current `DJICameraVideoResolution` and `DJICameraVideoFrameRate`.
 */
@property (nonatomic, readonly) int availableRecordingTimeInSeconds;

/**
 *  SSD's remaining capacity in MB.
 */
@property (nonatomic, readonly) int remainingSpaceInMegaBytes;

/**
 *  Video resolution to be saved to SSD.
 */
@property (nonatomic, readonly) DJICameraVideoResolution videoResolution;

/**
 *  Video framerate to be saved to SSD.
 */
@property (nonatomic, readonly) DJICameraVideoFrameRate videoFrameRate;



@end
