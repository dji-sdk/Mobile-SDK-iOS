//
//  DJIGimbal.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

@class DJIGimbal;
@class DJIGimbalCapacity;

/**
 *  Gimbal attitude
 */
typedef struct
{
    /**
     *  Pitch
     */
    float pitch;
    /**
     *  Roll
     */
    float roll;
    /**
     *  Yaw
     */
    float yaw;
} DJIGimbalAttitude;

/**
 *  Rotation direction
 */
typedef NS_ENUM(uint8_t, DJIGimbalRotationDirection){
    /**
     *  Forward
     */
    RotationForward,
    /**
     *  Backward
     */
    RotationBackward,
};

/**
 *  Rotation angle value description
 */
typedef NS_ENUM(uint8_t, DJIGimbalRotationAngleType){
    /**
     *  The angle value is relative value
     */
    RelativeAngle,
    /**
     *  The angle value is absolute value
     */
    AbsoluteAngle,
};

typedef struct
{
    /**
     *  The gimbal is rotation enable.
     */
    BOOL enable;
    /**
     *  The gimbal rotation angle.
     */
    float angle;
    /**
     *  The gimbal rotation type
     */
    DJIGimbalRotationAngleType angleType;
    /**
     *  The gimbal rotation direction
     */
    DJIGimbalRotationDirection direction;
} DJIGimbalRotation;

/**
 *  Gimbal error
 */
typedef NS_ENUM(uint8_t, DJIGimbalError)
{
    /**
     *  No error
     */
    GimbalErrorNone,
    /**
     *  Gimbal's motor abnormal
     */
    GimbalMotorAbnormal,
    /**
     *  Gimbal clamped
     */
    GimbalClamped,
};

/**
 *  Gimbal work mode
 */
typedef NS_ENUM(uint8_t, DJIGimbalWorkMode){
    /**
     *  Free mode (not follow)
     */
    GimbalFreeMode,
    /**
     *  FPV mode
     */
    GimbalFpvMode,
    /**
     *  Follow Yaw mode
     */
    GimbalYawFollowMode,
    /**
     *  Unknown
     */
    GimbalWorkModeUnknown = 0xFF,
};

/*
 *  Gimbal State
 */
@interface DJIGimbalState : NSObject
/**
 *  Gimbal's attitude: pitch roll yaw
 */
@property(nonatomic, readonly) DJIGimbalAttitude attitude;

/**
 *  Roll fine-tune value. The real roll adjust angle = rollFineTune * 0.1
 */
@property(nonatomic, readonly) NSInteger rollFineTune;

/**
 *  Gimbal's work mode
 */
@property(nonatomic, readonly) DJIGimbalWorkMode workMode;

/**
 *  The gimbal's have been reseted.
 */
@property(nonatomic, readonly) BOOL isAttitudeReset;

/**
 *  The gimbal is in calibrating
 */
@property(nonatomic, readonly) BOOL isCalibrating;

/**
 *  Whether or nor the calibration is succeeded. Value is valid while 'isCalibrating' changed from YES to NO.
 */
@property(nonatomic, readonly) BOOL isCalibrationSueeeeded;

/**
 *  Pitch reaches max
 */
@property(nonatomic, readonly) BOOL isPitchReachMax;

/**
 *  Roll reaches max
 */
@property(nonatomic, readonly) BOOL isRollReachMax;

/**
 *  Yaw reaches max
 */
@property(nonatomic, readonly) BOOL isYawReachMax;

@end


/*
 *  GimbalAttitudeResult
 *
 *  Discussion:
 *    Typedef of block to be invoked when the remote attitude data get Succeeded.
 */
typedef void (^GimbalAttitudeResultBlock)(DJIGimbalAttitude attitude);

@protocol DJIGimbalDelegate <NSObject>

@optional


/*
 *  Gimbal Error Handler
 *
 *  Discussion:
 *    error delegate to be invoked when detect a gimbal error.
 */
-(void) gimbalController:(DJIGimbal*)controller didGimbalError:(DJIGimbalError)error;

/*
 *  Gimbal state update. Not supported on phantom gimbal.
 *
 */
-(void) gimbalController:(DJIGimbal *)controller didUpdateGimbalState:(DJIGimbalState*)gimbalState;

@end

@interface DJIGimbal : DJIObject

@property(nonatomic, weak) id<DJIGimbalDelegate> delegate;

/**
 *  the attitude update time interval, the value should not smaller than 25ms. Default value is 50ms
 */
@property(nonatomic, assign) int attitudeUpdateInterval;

/*
 *  gimbalAttitude
 *
 *  Discussion:
 *			Returns the latest gimbal attitude data, or nil if none is available.
 */
@property(nonatomic, readonly) DJIGimbalAttitude gimbalAttitude;

/**
 *  Get the gimbal's capacity.
 *
 *  @return gimbal capacity, return nil if connection failured.
 */
-(DJIGimbalCapacity*) getGimbalCapacity;

/**
 *  Get gimbal's firmware version
 *
 *  @param block Remote execute result callback.
 */
-(void) getVersionWithResult:(void(^)(NSString* version, DJIError* error))block;

/*
 *  Starts gimbal attitude updates with no handler. To receive the latest attitude data
 *			when desired, examine the gimbalAttitude property.
 */
-(void) startGimbalAttitudeUpdates;

/*
 *	Stops gimbal attitude updates.
 */
-(void) stopGimbalAttitudeUpdates;

/*
 *  Gimbal Attitude Handler. Typedef of block to be invoked when remote gimbal attitude data is available.
 */
-(void) startGimbalAttitudeUpdateToQueue:(NSOperationQueue*)queue withResultBlock:(GimbalAttitudeResultBlock)block;

/**
 *  Set FPV mode. Typedef of block to be invoked when fpv mode is set success.
 *
 */
-(void) setGimbalFpvMode:(BOOL)isFpv withResult:(DJIExecuteResultBlock)block;

/**
 *  Set gimbal's pitch roll yaw rotation.
 *
 *  @param pitch Gimbal's pitch rotation parameter
 *  @param roll Gimbal's roll rotation parameter
 *  @param yaw Gimbal's yaw rotation parameter
 */
-(void) setGimbalPitch:(DJIGimbalRotation)pitch Roll:(DJIGimbalRotation)roll Yaw:(DJIGimbalRotation)yaw withResult:(DJIExecuteResultBlock)block;

@end
