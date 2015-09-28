//
//  DJIDrone.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIFoundation.h>

@class DJICamera;
@class DJIMainController;
@class DJIGimbal;
@class DJIRangeExtender;
@class DJIBattery;
@class DJIImageTransmitter;
@class DJIRemoteController;
@class DJIMediaManager;
@class DJIError;
@protocol DJIDroneDelegate;

/**
 *  Device name for camera
 */
DJI_API_EXTERN NSString* const kDJIDeviceCamera;

/**
 *  Device name for gimbal
 */
DJI_API_EXTERN NSString* const kDJIDeviceGimbal;

/**
 *  Device name for battery
 */
DJI_API_EXTERN NSString* const kDJIDeviceBattery;

/**
 *  Device name for main controller
 */
DJI_API_EXTERN NSString* const kDJIDeviceMainController;

/**
 *  Device name for remote controller
 */
DJI_API_EXTERN NSString* const kDJIDeviceRemoteController;

/**
 *  Device name for image transmitter
 */
DJI_API_EXTERN NSString* const kDJIDeviceImageTransmitter;

/**
 *  Device name for range extender
 */
DJI_API_EXTERN NSString* const kDJIDeviceRangeExtender;

/**
 *  Drone type
 */
typedef NS_ENUM(NSInteger, DJIDroneType){
    /**
     *  Type for product Phantom 2 vision / Phantom 2 vision+
     */
    DJIDrone_Phantom,
    /**
     *  Type for product Inspire / Matrice 100
     */
    DJIDrone_Inspire,
    /**
     *  Type for product Phantom3 Professional
     */
    DJIDrone_Phantom3Professional,
    /**
     *  Type for product Phantom3 Advanced
     */
    DJIDrone_Phantom3Advanced,
    /**
     *  Unknown type
     */
    DJIDrone_Unknown,
};

typedef NS_ENUM(NSUInteger, DJIConnectionStatus)
{
    /**
     *  Start reconnect: Broken -> Reconnect -> Succeeded/Failed
     */
    ConnectionStartConnect,
    /**
     *  Reconnect Succeeded: Reconnect -> Succeeded -> Broken
     */
    ConnectionSucceeded,
    /**
     *  Reconnect Failed: Reconnect -> Failed -> Reconnect
     */
    ConnectionFailed,
    /**
     *  Connection broken: Succeeded -> Broken -> Reconnect
     */
    ConnectionBroken,
};

@interface DJIDrone : NSObject
{
    DJIDroneType _droneType;
}

/**
 *  Drone delegate
 */
@property(nonatomic, weak) id<DJIDroneDelegate> delegate;

/**
 *  Whether or not the app is connected to the drone. Actually, for the Inpsire/Phantom 3 PRO/Phantom 3 Advanced this property just indicate the connection status to the remote controller. 
 */
@property(nonatomic, readonly) BOOL isConnected;

/**
 *  Drone type
 */
@property(nonatomic, readonly) DJIDroneType droneType;

/**
 *  Drone's camera.
 */
@property(nonatomic, readonly) DJICamera* camera;

/**
 *  Drone's main controller.
 */
@property(nonatomic, readonly) DJIMainController* mainController;

/**
 *  Drone's gimbal.
 */
@property(nonatomic, readonly) DJIGimbal* gimbal;

/**
 *  Range extender.
 */
@property(nonatomic, readonly) DJIRangeExtender* rangeExtender;

/**
 *  Smart battery
 */
@property(nonatomic, readonly) DJIBattery* smartBattery;

/**
 *  Image transmitter
 */
@property(nonatomic, readonly) DJIImageTransmitter* imageTransmitter;

/**
 *  Remote Controller
 */
@property(nonatomic, readonly) DJIRemoteController* remoteController;

/**
 *  init drone object with type
 *
 */
-(id) initWithType:(DJIDroneType)type;

/**
 *  Connect to the drone. once this function was called, the DJIDrone will automatically connect to the drone
 */
-(void) connectToDrone;

/**
 *  Disconnect to the drone.
 */
-(void) disconnectToDrone;

/**
 *  Destroy the drone object, user should call this interface to release all objects.
 */
-(void) destroy DJI_API_DEPRECATED;

@end

@protocol DJIDroneDelegate <NSObject>

/**
 *  Notify on connection status changed.
 *
 *  @param status Connection status
 */
-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status;

@end