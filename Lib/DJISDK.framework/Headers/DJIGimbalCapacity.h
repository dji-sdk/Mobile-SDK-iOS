//
//  DJIGimbalCapacity.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJIGimbalCapacity : NSObject

/**
 *  Show whether Pitch can be control
 */
@property(nonatomic) BOOL pitchAvailable;

/**
 *  Show whether Roll can be control
 */
@property(nonatomic) BOOL rollAvailable;

/**
 *  Show whether Yaw can be control
 */
@property(nonatomic) BOOL yawAvailable;

/**
 *  Max controlled angle of pitch
 */
@property(nonatomic) float maxPitchRotationAngle;

/**
 *  Min controlled angle of  pitch
 */
@property(nonatomic) float minPitchRotationAngle;

/**
 *  Max controlled angle of roll rotation
 */
@property(nonatomic) float maxRollRotationAngle;

/**
 *  Min controlled angle of roll rotation
 */
@property(nonatomic) float minRollRotationAngle;

/**
 *  Max controlled angle of yaw rotation
 */
@property(nonatomic) float maxYawRotationAngle;

/**
 *  Min controlled angle of  yaw rotation
 */
@property(nonatomic) float minYawRotationAngle;

@end
