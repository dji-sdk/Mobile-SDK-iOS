//
//  DJISDKCamera.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJICamera.h>

@interface DJIPhantomCamera : DJICamera

/**
 *  Get the camera's firmware version
 *
 *  @return Return the firmware version of the camera. return nil if disconnected.
 */
-(NSString*) getCameraVersion;

/**
 *  Take photo with mode, if the capture mode is CameraMultiCapture or CameraContinousCapture, you should call stopTakePhotoWithResult to stop photoing
 *
 *  @param captureMode Tell the camera what capture action will be do, if capture mode is multi capture or continuous capture, user should call the 'stopTakePhotWithResult' to stop catpture if need.
 *  @param block  The remote execute result.
 */
-(void) startTakePhoto:(CameraCaptureMode)captureMode withResult:(DJIExecuteResultBlock)block;

/**
 *  Stop the mutil capture or continous capture. should match the startTakePhoto action.
 *
 *  @param block       The remote execute result
 */
-(void) stopTakePhotoWithResult:(DJIExecuteResultBlock)block;

/**
 *  Start recording
 *
 *  @param block The remote execute result
 */
-(void) startRecord:(DJIExecuteResultBlock)block;

/**
 *  Stop recording
 *
 *  @param block The remote execute result
 */
-(void) stopRecord:(DJIExecuteResultBlock)block;

/**
 *  Start the camera system state updates.
 */
-(void) startCameraSystemStateUpdates;

/**
 *  Stop the camera system state updates
 */
-(void) stopCameraSystemStateUpdates;

@end

@interface DJIPhantomCamera (CameraSettings)

/**
 *  Set the video quality, e.g. 640x480
 *
 *  @param videoQuality Video quality to be set
 *  @param block        The remote execute result callback.
 *  @attention If the parameters was configured Succeeded, the remote video module will restart
 */
-(void) setVideoQuality:(VideoQuality)videoQuality withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Set the photo's pixel size. The camera will used this size to storage photo after taking photo.
 *
 *  @param photoSize Photo's pixel size
 *  @param block     The remote execute result callback.
 */
-(void) setCameraPhotoSize:(CameraPhotoSizeType)photoSize withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's photo pixel size parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraPhotoSize:(void (^)(CameraPhotoSizeType photoSize, DJIError* error))block;

/**
 *  Set camera's ISO parameter.
 *
 *  @param isoType Iso type
 *  @param block   The remote execute result callback.
 */
-(void) setCameraISO:(CameraISOType)isoType withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's ISO parameter.
 *
 *  @param block The remote execute result block
 */
-(void) getCameraISO:(void (^)(CameraISOType iso, DJIError* error))block;

/**
 *  Set the camera's white balance parameter.
 *
 *  @param whiteBalance White balance parameter.
 *  @param block        The remote execute result callback.
 */
-(void) setCameraWhiteBalance:(CameraWhiteBalanceType)whiteBalance withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's white balance parameter
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraWhiteBalance:(void (^)(CameraWhiteBalanceType whiteBalance, DJIError* error))block;

/**
 *  Set the camera's exposure metering parameter
 *
 *  @param meteringType Exposure metering
 *  @param block        The remote execute result  callback.
 */
-(void) setCameraExposureMetering:(CameraExposureMeteringType)meteringType withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's exposure metering parameter
 *
 *  @param block The remote execute result block callback.
 */
-(void) getCameraExposureMetering:(void (^)(CameraExposureMeteringType exposureMetering, DJIError* error))block;

/**
 *  Set the camera's recording resolution and fov parameter.
 *
 *  @param resolution Recording resolution is used by camera while in recording.
 *  @param fov        Recording FOV is used by camera while in recording.
 *  @param block      The remote execute result callback.
 */
-(void) setCameraRecordingResolution:(CameraRecordingResolutionType)resolution andFOV:(CameraRecordingFovType)fov withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's recording resolution and fov parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraRecordingResolution:(void (^)(CameraRecordingResolutionType resolution, CameraRecordingFovType fov, DJIError* error))block;

/**
 *  Set the camera's photo storage format.
 *
 *  @param photoFormat Photo storage format is used by camera after take photo.
 *  @param block       The remote execute result callback.
 */
-(void) setCameraPhotoFormat:(CameraPhotoFormatType)photoFormat withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's photo storage format.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraPhotoFormat:(void(^)(CameraPhotoFormatType photoFormat, DJIError* error))block;

/**
 *  Set the camera's exposure compensation parameter.
 *
 *  @param compensationType Camera's exposure compensation parameter.
 *  @param block            The remote execute result callback.
 */
-(void) setCameraExposureCompensation:(CameraExposureCompensationType)compensationType withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get camera's exposure compensation parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraExposureCompensation:(void (^)(CameraExposureCompensationType exposureCompensation, DJIError* error))block;

/**
 *  Set the camera's anti flicker parameter
 *
 *  @param antiFlickerType Camera's anti flicker parameter.
 *  @param block           The remote execute result callback.
 */
-(void) setCameraAntiFlicker:(CameraAntiFlickerType)antiFlickerType withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's anti flicker parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraAntiFlicker:(void (^)(CameraAntiFlickerType antiFlicker, DJIError* error))block;

/**
 *  Set the camera's sharpness parameter.
 *
 *  @param sharpness Camera's sharpness parameter.
 *  @param block     The remote execute result callback.
 */
-(void) setCameraSharpness:(CameraSharpnessType)sharpness withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get camera's sharpness parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraSharpness:(void (^)(CameraSharpnessType sharpness, DJIError* error))block;

/**
 *  Set the camera's contrast parameter.
 *
 *  @param contrast Camera's contrast parameter
 *  @param block    The remote execute result callback.
 */
-(void) setCameraContrast:(CameraContrastType)contrast withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get camera's contrast parameter.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraContrast:(void(^)(CameraContrastType contrast, DJIError* error))block;

/**
 *  Sync local time to camera. the camera should had synced time from device while doing take photo or record action, or the camera will return "Time Not Sync" error
 *
 *  @param block The remote execute result callback.
 */
-(void) syncTime:(DJIExecuteResultBlock)block;

/**
 *  Set the camera's GPS parameter. The gps parameter will write into meta data of photo or video file.
 *
 *  @param gps   GPS
 *  @param block The remote execute result callback.
 */
-(void) setCameraGps:(CLLocationCoordinate2D)gps withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's GPS
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraGps:(void (^)(CLLocationCoordinate2D coordinate, DJIError* error))block;

/**
 *  Set multi capture count.
 *
 *  @param count Multi capture count
 *  @param block The remote execute result callback.
 */
-(void) setMultiCaptureCount:(CameraMultiCaptureCount)count withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get multi capture count.
 *
 *  @param block The remote execute result callback.
 */
-(void) getMultiCaptureCount:(void(^)(CameraMultiCaptureCount multiCaptureCount, DJIError* error))block;

/**
 *  Set the camera's continuous capture parameters
 *
 *  @param block  The remote execute result callback.
 */
-(void) setContinuousCapture:(CameraContinuousCapturePara)capturePara withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's continuous capture parameters
 *
 *  @param block The remote execute result callback.
 */
-(void) getContinuousCaptureParam:(void(^)(CameraContinuousCapturePara capturePara, DJIError* error))block;

/**
 *  Set the camera how to do while the connection was broken.
 *
 *  @param action How the Camera will action while the connection broken.
 *  @param block  The remote execute result callback.
 */
-(void) setCameraActionWhenConnectionBroken:(CameraActionWhenBreak)action withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's action settings while the connection was broken.
 *
 *  @param block The remote execute result callback.
 */
-(void) getCameraActionWhenConnectionBroken:(void(^)(CameraActionWhenBreak cameraAction, DJIError* error))block;

/**
 *  Save the camera's settings permanently. or the settings will be lost after camera restart.
 *
 *  @param block The remote execute result callback.
 */
-(void) saveCameraSettings:(DJIExecuteResultBlock)block;

/**
 *  Restore the default built-in settings.
 *
 *  @param block The remote execute result callback.
 */
-(void) restoreCameraDefaultSettings:(DJIExecuteResultBlock)block;

/**
 *  Set the camera's mode. The camera mode decide how the camera work. In CameraUSBMode, could not take photo, recording or change camera parameters, in this mode, we could use - fetchMediaListWithResultBlock: API to access medias file on SD card and download medias file from SD carad.
 *
 *  @param mode  Camera mode
 *  @param block The remote execute result callback.
 */
-(void) setCamerMode:(CameraMode)mode withResultBlock:(DJIExecuteResultBlock)block;

/**
 *  Get the camera's photo name prefix
 *
 *  @param block The remote execute result block
 */
-(void) getCameraPhotoNamePrefix:(void (^)(NSString* prefix, DJIError* error))block;

/**
 *  Set the camera's photo name prefix. The new name prefix must have only four fixed characters, and the  prefix should be comprised of character 'A' - 'Z' and '_'. for example "DJI_".
 *
 *  @param prefix New photo name prefix.
 *  @param block  The remote execute result block
 */
-(void) setCameraPhotoNamePrefix:(NSString*)prefix withResultBlock:(DJIExecuteResultBlock)block;

@end

@interface DJIPhantomCamera (Media)

/**
 *  Fetch media list from remote album.
 *
 *  @param block The remote execute result block
 *  @attention The camera mode should be set as 'CameraUSBMode'.
 */
-(void) fetchMediaListWithResultBlock:(void(^)(NSArray* mediaList, NSError* error))block;

@end
