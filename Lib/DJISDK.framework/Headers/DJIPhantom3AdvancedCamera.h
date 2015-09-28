//
//  DJIPhantom3AdvancedCamera.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJICamera.h>
#import <DJISDK/DJICameraSettingsDef.h>

@interface DJIPhantom3AdvancedCamera : DJICamera

/**
 *  Get the camera's firmware version
 *
 *  @return Return the firmware version of the camera.
 */
-(NSString*) getCameraVersion DJI_API_DEPRECATED;

/**
 *  Take photo with mode, if the capture mode is CameraMultiCapture or CameraContinousCapture, user should call stopTakePhotoWithResult to stop photoing if needed. User should check the SD card state before calling this API.
 *
 *  @param captureMode Capture mode.
 *  @param block       The remote execute result callback.
 */
-(void) startTakePhoto:(CameraCaptureMode)captureMode withResult:(DJIExecuteResultBlock)block;

/**
 *  Stop the multi capture or continous capture.
 *
 *  @param block The remote execute result callback.
 */
-(void) stopTakePhotoWithResult:(DJIExecuteResultBlock)block;

/**
 *  Start recording. User should check the SD card state before calling this API.
 *
 *  @param block The remote execute result callback.
 */
-(void) startRecord:(DJIExecuteResultBlock)block;

/**
 *  Stop recording.
 *
 *  @param block The remote execute result
 */
-(void) stopRecord:(DJIExecuteResultBlock)block;

/**
 *  Start the camera's system state updates.
 */
-(void) startCameraSystemStateUpdates;

/**
 *  Stop the camera's system state updates.
 */
-(void) stopCameraSystemStateUpdates;

/**
 *  Set camera's work mode.
 *
 *  @param mode  Work mode for camera.
 *  @param block Remote execute result callback.
 */
-(void) setCameraWorkMode:(CameraWorkMode)mode withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's work mode.
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraWorkModeWithResult:(void (^)(CameraWorkMode, DJIError *))block;

@end

@interface DJIPhantom3AdvancedCamera (Media)

/**
 *  Fetch media list from remote album. The camera's work mode should be set as CameraWorkModePlayback or CameraWorkModeDownload before call this api.
 *
 *  @param block Remote execute result. Objects in mediaList is kind of class DJIMedia.
 */
-(void) fetchMediaListWithResultBlock:(void (^)(NSArray* mediaList, NSError* error))block;

/**
 *  Delete media from remote album. The camera's work mode should be set as CameraWorkModePlayback or CameraWorkModeDownload before call this api.
 *
 *  @param medias Medias to be delete.
 *  @param block  Remote execute result, 'failureDeletes' will contain medias which failured delete.
 */
-(void) deleteMedias:(NSArray*)medias withResult:(void(^)(NSArray* failureDeletes, DJIError* error))block;

@end

@interface DJIPhantom3AdvancedCamera (CameraSettings)

/**
 *  Save camera's current setting to the specific user.
 *
 *  @param settings Specific user to store the settings.
 *  @param result   Remote execute result callback.
 */
-(void) saveCameraSettingsTo:(CameraUserSettings)settings withResult:(DJIExecuteResultBlock)result;

/**
 *  Load specific settings form user.
 *
 *  @param settings Settings to be load
 *  @param result   Remote execute result callback.
 */
-(void) loadCameraSettingsFrom:(CameraUserSettings)settings withResult:(DJIExecuteResultBlock)result;

/**
 *  Set camera's exposure mode
 *
 *  @param mode  Exposure mode to be set
 *  @param block Remote execute result callback
 */
-(void) setCameraExposureMode:(CameraExposureMode)mode withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's exposure mode setting
 *
 *  @param block Remote execute result callback
 */
-(void) getCameraExposureModeWithResult:(void (^)(CameraExposureMode, DJIError *))block;

/**
 *  Set camera's photo size
 *
 *  @param photoSize Photo size set to camera
 *  @param ratio     Photo ration set to camera
 *  @param block     Remote execute result callback
 */
-(void) setCameraPhotoSize:(CameraPhotoSizeType)photoSize andRatio:(CameraPhotoRatioType)ratio withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's photo size setting
 *
 *  @param block Remote execute result callback
 */
-(void) getCameraPhotoSizeAndRatioWithResult:(void(^)(CameraPhotoSizeType photoSize, CameraPhotoRatioType ratio, DJIError* error))block;

/**
 *  Set camera's photo quality
 *
 *  @param quality Photo quality set to camera
 *  @param block   Remote execute result callback
 */
-(void) setCameraPhotoQuality:(CameraPhotoQualityType)quality withResult:(DJIExecuteResultBlock)block;

/**
 *  Get cameras' photo quality setting
 *
 *  @param block Remote execute result callback
 */
-(void) getCameraPhotoQualityWithResult:(void(^)(CameraPhotoQualityType quality, DJIError* error))block;

/**
 *  Set spot metering area. the area size is row(12) by column(8). so the areaIndex value is in range [0, 95]
 *
 *  @param areaIndex Area index set to camera
 *  @param block     Remote execute result callback
 */
-(void) setCameraSpotMeteringArea:(uint8_t)areaIndex withResult:(DJIExecuteResultBlock)block;

/**
 *  Get spot metering area index
 *
 *  @param block Remote execute result callback
 */
-(void) getCameraSpotMeteringAreaWithResult:(void(^)(uint8_t areaIndex, DJIError* error))block;

/**
 *  Set camera shutter speed. the avaliable value of shutterSpeed is defined as DJICameraShutterSpeedx.
 *
 *  attention:
 *    the shutterSpeed should not faster then the video frame rate when the camera is under CameraWorkModeRecord. for example: video frame rate = 30fps, then the shutterSpeed must <= 1/30. CameraWorkModeCapture has no any limitation.
 *
 *  @param shutterSpeed Shutter speed set to camear
 *  @param block        Remote execute result callback.
 */
-(void) setCameraShutterSpeed:(double)shutterSpeed withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's shutter speed settings
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraShutterSpeedWithResult:(void(^)(double shutterSpeed, DJIError* error))block;

/**
 *  Set camera's Colour temperature.
 *
 *  @param temperature Colour temperature value in range [20, 100]
 *  @param block       Remote execute result callback.
 */
-(void) setCameraColourTemperature:(uint8_t)temperature withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's colour temperature settings
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraColourTemperatureWithResult:(void(^)(uint8_t temperature, DJIError* error))block;

/**
 *  Set camera's saturation
 *
 *  @param saturation Saturation in range [-3, 3]
 *  @param block      Remote execute result callback.
 */
-(void) setCameraSaturation:(int8_t)saturation withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's saturation
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraSaturationWithResult:(void(^)(int8_t saturation, DJIError* error))block;

/**
 *  Set camera's Hue
 *
 *  @param hue   Hue in range [-3, 3]
 *  @param block Remote execute result callback.
 */
-(void) setCameraHue:(int8_t)hue withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's hue settings
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraHueWithResult:(void(^)(int8_t hue, DJIError* error))block;

/**
 *  Set camera's digital filter.
 *
 *  @param filter Digital filter set to camera
 *  @param block  Remote execute result callback.
 */
-(void) setCameraDigitalFilter:(CameraDigitalFilter)filter withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's digital filter settings
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraDigitalFilterWithResult:(void(^)(CameraDigitalFilter filter, DJIError* error))block;

/**
 *  Set camra's file index mode. if set as CameraFileIndexReset, the new file will be start as index 1 when you change a new SD card.
 *
 *  @param fileIndex File index mode set to camera
 *  @param result    Remote execute result callback.
 */
-(void) setCameraFileIndexMode:(CameraFileIndexMode)fileIndex withResult:(DJIExecuteResultBlock)result;

/**
 *  Get camera's file index mode.
 *
 *  @param result Remote execute result callback.
 */
-(void) getCameraFileIndexModeWithResult:(void(^)(CameraFileIndexMode fileIndex, DJIError* error))result;

/**
 *  Set camera's AEB continue capture parameters
 *
 *  @note The CameraAEBParam's continueCaptureCount just support 3 or 5 right now. and 'exposureOffset' not support right now.
 *  @param aebParam AEB capture parameters set to camera
 *  @param result   Remote execute result callback.
 */
-(void) setCameraAEBParam:(CameraAEBParam)aebParam withResult:(DJIExecuteResultBlock)result;

/**
 *  Get camera's AEB parameters
 *
 *  @param result Remote execute result callback.
 */
-(void) getCameraAEBParamWithResult:(void(^)(CameraAEBParam aeb, DJIError* error))result;

/**
 *  Set camera AE lock
 *
 *  @param isLock Lock or unlock AE
 *  @param result Remote execute result callback.
 */
-(void) setCameraAELock:(BOOL)isLock withResult:(DJIExecuteResultBlock)result;

/**
 *  Get camera's AE lock status
 *
 *  @param result Remote execute result callback.
 */
-(void) getCameraAELockWithResult:(void(^)(BOOL isLocked, DJIError* error))result;

@end

@interface DJIPhantom3AdvancedCamera (VideoSettings)

/**
 *  Set camera's video quality
 *
 *  @param quality Video quality set to camera
 *  @param block   Remote execute result callback.
 */
-(void) setCameraVideoQuality:(VideoQuality)quality withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's video quality
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraVideoQualityWithResult:(void(^)(VideoQuality quality, DJIError* error))block;

/**
 *  Set camera's video resolution and frame rate. The supported resolution and frame rate is below:
 *  PAL:
        1920x1080P_24fps
        1920x1080P_25fps
        1920x1080P_48fps
        1920x1080P_50fps
        1280x720P_24fps
        1280x720P_25fps
        1280x720P_48fps
        1280x720P_50fps
 
    NTSC:
        1920x1080P_24fps
        1920x1080P_30fps
        1920x1080P_48fps
        1920x1080P_60fps
        1280x720P_24fps
        1280x720P_30fps
        1280x720P_48fps
        1280x720P_60fps
 *
 *  @param resolution Resolute of video
 *  @param rate       Frame rate of video
 *  @param block      Remote execute result callback.
 */
-(void) setCameraVideoResolution:(CameraVideoResolution)resolution andFrameRate:(CameraVideoFrameRate)rate withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's video resolution and frame rate
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraVideoResolutionAndFrameRate:(void(^)(CameraVideoResolution resolution, CameraVideoFrameRate rate, DJIError* error))block;

/**
 *  Set camera's video storage format
 *
 *  @param format Storage format for video
 *  @param block  Remote execute result callback.
 */
-(void) setCameraVideoStorageFormat:(CameraVideoStorageFormat)format withResult:(DJIExecuteResultBlock)block;

/**
 *  Get camera's video storage format settings
 *
 *  @param block Remote execute result callback.
 */
-(void) getCameraVideoStorageFormatWithResult:(void(^)(CameraVideoStorageFormat format, DJIError* error))block;

/**
 *  Set camera's video standard.
 *
 *  @param videoStandard Video standard set to camera
 *  @param result        Remote execute result callback.
 */
-(void) setCameraVideoStandard:(CameraVideoStandard)videoStandard withResult:(DJIExecuteResultBlock)result;

/**
 *  Get camera's video staandard.
 *
 *  @param result Remote execute result callback.
 */
-(void) getCameraVideoStandardWithResult:(void(^)(CameraVideoStandard videoStandard, DJIError* error))result;


@end

