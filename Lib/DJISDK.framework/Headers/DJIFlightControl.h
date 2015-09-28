//
//  DJIFlightController.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIFoundation.h>
#import "DJIObject.h"

/**
 *  Flight control coordinate system
 */
typedef NS_ENUM(uint8_t, DJIFlightCoordinateSystem){
    /**
     *  Ground coordinate system
     */
    DJIFlightCoordinateSystemGround,
    /**
     *  Body coordinate system
     */
    DJIFlightCoordinateSystemBody,
};

/**
 *  Vertical control velocity MIN value
 */
DJI_API_EXTERN const float DJIVerticalControlMinVelocity;
/**
 *  Vertical control velocity MAX value
 */
DJI_API_EXTERN const float DJIVerticalControlMaxVelocity;

/**
 *  Vertical control mode, will affect the mThrottle of DJIFlightControlData
 */
typedef NS_ENUM(uint8_t, DJIVerticalControlMode){
    /**
     *  The value of mThrottle is a velocity value. mThrottle value will in range [-4, 4] m/s
     */
    DJIVerticalControlVelocity,
    /**
     *  The value of mThrottle is a position value. mThrottle value will in range [0, +∞) m. value is offset  position to the ground.
     */
    DJIVerticalControlPosition,
};

/**
 *  Horizontal control velocity MAX value
 */
DJI_API_EXTERN const float DJIHorizontalControlMaxVelocity;
/**
 *  Horizontal control velocity MIN value
 */
DJI_API_EXTERN const float DJIHorizontalControlMinVelocity;
/**
 *  Horizontal control angle MAX value
 */
DJI_API_EXTERN const float DJIHorizontalControlMaxAngle;
/**
 *  Horizontal control angle MIN value
 */
DJI_API_EXTERN const float DJIHorizontalControlMinAngle;

/**
 *  Horizontal control mode, will affect the mPitch and mRoll of DJIFlightControlData
 */
typedef NS_ENUM(uint8_t, DJIHorizontalControlMode){
    /**
     *  The value of mPitch and mRoll is a angle value. mPitch and mRoll will in range [-30, 30] degree
     */
    DJIHorizontalControlAngle,
    /**
     *  The value of mPitch and mRoll is a velocity value. mPitch and mRoll will in range [-10, +10] m/s
     */
    DJIHorizontalControlVelocity,
};

/**
 *  Yaw control angle MAX value
 */
DJI_API_EXTERN const float DJIYawControlMaxAngle;
/**
 *  Yaw control angle MIN value
 */
DJI_API_EXTERN const float DJIYawControlMinAngle;
/**
 *  Yaw control palstance MAX value
 */
DJI_API_EXTERN const float DJIYawControlMaxPalstance;
/**
 *  Yaw control palstance MIN value
 */
DJI_API_EXTERN const float DJIYawControlMinPalstance;

/**
 *  Yaw control mode, will affect the mYaw of DJIFlightControlData
 */
typedef NS_ENUM(uint8_t, DJIYawControlMode){
    /**
     *  The value of mYaw is a angle value, mYaw will in range [-180, 180] degree
     */
    DJIYawControlAngle,
    /**
     *  The value of mYaw is a palstance value. mYaw will in range [-100, 100] degree/s
     */
    DJIYawControlPalstance,
};

/**
 *  Flight controlled quantity
 */
typedef float DJIFlightControlledQuantity;

typedef struct
{
    /**
     *  Aircraft's Pitch controlled quantity.
     */
    DJIFlightControlledQuantity mPitch;
    /**
     *  Aircraft's Roll controlled quantity.
     */
    DJIFlightControlledQuantity mRoll;
    /**
     *  Aircraft's Yaw controlled quantity.
     */
    DJIFlightControlledQuantity mYaw;
    /**
     *  Aircraft's Throttle controlled quantity.
     */
    DJIFlightControlledQuantity mThrottle;
} DJIFlightControlData;

@protocol DJIFlightControl <NSObject>

/**
 *  Whether flight control enable. If there are other mission is in running or not in navigation mode then return NO.
 */
@property(nonatomic, readonly) BOOL isEnable;

/**
 *  Vertical control mode
 */
@property(nonatomic, assign) DJIVerticalControlMode verticalControlMode;
/**
 *  Horizontal control mode
 */
@property(nonatomic, assign) DJIHorizontalControlMode horizontalControlMode;
/**
 *  Yaw control mode
 */
@property(nonatomic, assign) DJIYawControlMode yawControlMode;
/**
 *  Horizontal control coordinate system
 */
@property(nonatomic, assign) DJIFlightCoordinateSystem horizontalCoordinateSystem;


/**
 *  Send flight control data. The property 'isEnable' should be YES.
 *
 *  @param controlData Flight control data
 *  @param result      Remote execute result callback.
 */
-(void) sendFlightControlData:(DJIFlightControlData)controlData withResult:(DJIExecuteResultBlock)result;

@end