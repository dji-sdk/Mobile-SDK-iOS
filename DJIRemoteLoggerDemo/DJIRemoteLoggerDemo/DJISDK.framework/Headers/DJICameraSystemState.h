/*
 *  DJI iOS Mobile SDK Framework
 *  DJICameraSystemState.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <DJISDK/DJICameraSettingsDef.h>

@interface DJICameraSystemState : NSObject

/**
 *  Show the camera is taking RAW capture or JPEG capture.
 *
 */
@property(nonatomic, readonly) BOOL isTakingRawCapture;

/**
 *  The camera is taking continuous capture.
 *
 */
@property(nonatomic, readonly) BOOL isTakingContinousCapture;

/**
 *  The camera is taking multi capture.
 */
@property(nonatomic, readonly) BOOL isTakingMultiCapture;

/**
 *  The camera is taking single capture.
 *
 */
@property(nonatomic, readonly) BOOL isTakingSingleCapture;

/**
 *  YES if the camera time is synced by the mobile or other device with time. DJICamera does not have
 *  timer.  Once it is restarted, the previous synced time will be lost. Check syncTime: method to see
 *  how to set time for the camera.
 */
@property(nonatomic, readonly) BOOL isCameraTimeSynced;

/**
 *  YES if camera is recording video
 */
@property(nonatomic, readonly) BOOL isRecording;

/**
 *  YES if camera is too hot.
 */
@property(nonatomic, readonly) BOOL isCameraOverHeated;

/**
 *  The camera's sensor error.
 */
@property(nonatomic, readonly) BOOL isCameraError;

/**
 *  Indicate whether the SD card exists in the camera.
 */
@property(nonatomic, readonly) BOOL isSDCardExist;

/**
 *  Indicate whether the camera is in usb mode.
 */
@property(nonatomic, readonly) BOOL isUSBMode;


/**
 *  Current mode of the camera.
 */
@property(nonatomic, readonly) DJICameraMode workMode;

/**
 *  Time of current video being recorded by camera in seconds.
 */
@property(nonatomic, readonly) int currentVideoRecordingTimeInSeconds;

@end
