//
//  DJICamera.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJICameraSettingsDef.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMedia;
@class DJICamera;
@class DJICameraSystemState;
@class DJICameraPlaybackState;
@class DJICameraLensState;
@class DJIMediaManager;
@class DJIPlaybackManager;

/*********************************************************************************/
#pragma mark - DJICameraSDCardState
/*********************************************************************************/

/**
 *  This class provides the SD card's general information and current status.
 *
 */
@interface DJICameraSDCardState : NSObject

/**
 *  YES if there is an SD card error.
 */
@property(nonatomic, readonly) BOOL hasError;

/**
 *  YES if the SD card is read only.
 */
@property(nonatomic, readonly) BOOL isReadOnly;

/**
 *  YES if SD card filesystem format is invalid.
 */
@property(nonatomic, readonly) BOOL isInvalidFormat;

/**
 *  YES if the SD card is formatted.
 */
@property(nonatomic, readonly) BOOL isFormatted;

/**
 *  YES if the SD card is formatting.
 */
@property(nonatomic, readonly) BOOL isFormatting;
/**
 *  YES if the SD card cannot save any more media.
 */
@property(nonatomic, readonly) BOOL isFull;

/**
 *  YES if the SD card is verified genuine. The SD card will not be valid if it is fake,
 *  which can be a problem if the SD card was purchased by a non-reputable retailer.
 */
@property(nonatomic, readonly) BOOL isVerified;

/**
 *  YES if SD card is inserted in camera.
 */
@property(nonatomic, readonly) BOOL isInserted;

/**
 *  Total space in Megabytes (MB) available on the SD card.
 */
@property(nonatomic, readonly) int totalSpaceInMegaBytes;

/**
 *  Remaining space in Megabytes (MB) on the SD card.
 */
@property(nonatomic, readonly) int remainingSpaceInMegaBytes;

/**
 *  Returns the number of pictures that can be taken with the remaining space available
 *  on the SD card.
 */
@property(nonatomic, readonly) int availableCaptureCount;

/**
 *  Returns the number of seconds available for recording with the remaining space available
 *  in the SD card.
 */
@property(nonatomic, readonly) int availableRecordingTimeInSeconds;

@end

/*********************************************************************************/
#pragma mark - DJICameraDelegate
/*********************************************************************************/

/**
 *  This protocol provides delegate methods to receive the updated video data, camera's current state and lens information.
 *
 */
@protocol DJICameraDelegate <NSObject>

@optional
/**
 *  Video data update callback. H.264 (also called MPEG-4 Part 10 Advanced Video Coding or MPEG-4 AVC)
 *  is a video coding format that is currently one of the most commonly used formats for the recording,
 *  compression, and distribution of video content.
 *
 *  @param camera      Camera that sends out the video data.
 *  @param videoBuffer H.264 video data buffer. Don't free the buffer after it has been used. The
 *  units for the video buffer are bytes.
 *  @param length      Size of the address of the video data buffer in bytes.
 */
- (void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size;

/**
 *  Updates the camera's current state.
 *
 *  @param camera      Camera that sends out the video data.
 *  @param systemState The camera's system state.
 */
- (void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState;

/**
 *  Tells the delegate that the lens information is updated.
 *  This protocol is available only when isChangeableLensSupported is YES.
 *
 *  @param camera      Camera that sends out the updatd lens information.
 *  @param lensState   The camera's lens state.
 */
- (void)camera:(DJICamera *)camera didUpdateLensState:(DJICameraLensState *)lensState;

@end

/*********************************************************************************/
#pragma mark - DJICamera
/*********************************************************************************/

/**
 *  This class contains media manager and playback manager to manage the Camera's media content. Also, it provides methods to change settings of the camera and perform
 *  actions of the camera.
 */
@interface DJICamera : DJIBaseComponent

/**
 *  Delegate that recevies the information pushed by the camera
 */
@property(nonatomic, weak) id<DJICameraDelegate> delegate;

/**
 *  Media Manager is used for interaction when camera is in DJICameraModeMediaDownload.
 *  User can only access to the manager when isMediaDownloadModeSupported returns YES.
 */
@property(nonatomic, readonly) DJIMediaManager *mediaManager;

/**
 *  Playback Manager is used for interaction when camera is in DJICameraModePlayback.
 *  User can only access to the manager when isPlaybackSupported returns YES.
 */
@property(nonatomic, readonly) DJIPlaybackManager *playbackManager;

//-----------------------------------------------------------------
#pragma mark Camera work mode
//-----------------------------------------------------------------
/**
 *  Sets the camera's work mode to taking pictures, video, playback or download. See enum DJICameraMode in
 *  DJICameraSettingsDef.h to find details on camera work modes. Please note that you cannot change the mode
 *  when a certain task is executing, e.g. taking photo(s), recording video, downloading and saving files.
 *
 *  @param mode  Camera work mode.
 *  @param block Remote execution result error block.
 */
- (void)setCameraMode:(DJICameraMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's current work mode.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCameraModeWithCompletion:(void (^)(DJICameraMode, NSError *_Nullable))block;

//-----------------------------------------------------------------
#pragma mark Shoot photos
//-----------------------------------------------------------------
/**
 *  Check if the current device supports Timelapse.
 *  Supported only by OSMO camera.
 */
- (BOOL)isTimeLapseSupported;

/**
 *  Camera starts to take photo with one of the camera capture modes (shoot
 *  photo modes).
 *
 *  Precondition:
 *   1. Camera must be in ShootPhoto mode.
 *   2. The SD card state should be checked before this method is used to
 *      ensure sufficient space exists.
 *  Post condition:
 *   If the capture mode is either Interval or Time-lapse, calling stopShootPhoto may be required for the camera to stop
 *   taking photos.
 *
 *  @param shootMode  Shoot photo mode for camera to start taking photos with.
 *  Check the enum named CameraShootPhotoMode in DJICameraSettingsDef to find all possible camera
 *  shoot modes.
 *  @param block  The execution callback with the execution result returned.
 */
- (void)startShootPhoto:(DJICameraShootPhotoMode)shootMode withCompletion:(DJICompletionBlock)block;

/**
 *  Camera stops taking photos.
 *
 *  Precondition:
 *   1. StartShootPhoto:withCompletion has been invoked and the shoot mode is either Interval or Time-lapse.
 *   2. The shoot photo operation is still executing.
 *
 *  @param block The execution callback with the execution result returned.
 */
- (void)stopShootPhotoWithCompletion:(DJICompletionBlock)block;

//-----------------------------------------------------------------
#pragma mark Record video
//-----------------------------------------------------------------
/**
 *  Check if the current device supports Slow Motion video recording.
 *  Currently Slow Motion is supported only by the OSMO camera.
 */
- (BOOL)isSlowMotionSupported;

/**
 *  Sets whether Slow Motion mode is enabled or not.
 *  When it is enabled, the resolution and frame rate will change to 1920x1080 120fps.
 *  When it is disabled, the reolution and frame rate will recover to previous setting.
 *  Supported only by OSMO camera.
 *
 *  @param enabled  Enable or disable Slow Motion video.
 *  @param block    The execution callback with the execution result returned.
 */
- (void)setVideoSlowMotionEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether Slow Motion mode is enabled or not.
 *  Supported only by the OSMO camera.
 *
 *  @param block The execution callback with the value(s) returned.
 */
- (void)getVideoSlowMotionEnabledWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Starts recording video. Camera must be in DJICameraModeRecordVideo work mode.
 */
- (void)startRecordVideoWithCompletion:(DJICompletionBlock)block;

/**
 *  Stops recording video.
 */
- (void)stopRecordVideoWithCompletion:(DJICompletionBlock)block;

@end

/*********************************************************************************/
#pragma mark - DJICamera (CameraSettings)
/*********************************************************************************/

@interface DJICamera (CameraSettings)

//-----------------------------------------------------------------
#pragma mark Camera basic settings
//-----------------------------------------------------------------

/**
 *  Sets the camera's file index mode. The default value of DJICameraFileIndexMode is set to DJICameraFileIndexModeReset.
 *
 *  @param fileIndex File index mode to be set for the camera's SD card.
 *  @param block     Remote execution result error block.
 */
- (void)setFileIndexMode:(DJICameraFileIndexMode)fileIndex withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's file index mode.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getFileIndexModeWithCompletion:(void (^)(DJICameraFileIndexMode fileIndex, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Video related
//-----------------------------------------------------------------

/**
 *  Sets the camera's video resolution and frame rate.
 *
 *  @warning The supported resolutions and frame rates for the two different analog television standards PAL and NSTC are below:
 *  PAL:4096x2160_24fps
 *      4096x2160_25fps
 *      3840x2160_24fps
 *      3840x2160_25fps
 *      1920x1080_24fps
 *      1920x1080_25fps
 *      1920x1080_48fps
 *      1920x1080_50fps
 *      1280x720_24fps
 *      1280x720_25fps
 *      1280x720_48fps
 *      1280x720_50fps
 *  NTSC:4096x2160_24fps
 *      3840x2160_24fps
 *      3840x2160_30fps
 *      1920x1080_24fps
 *      1920x1080_30fps
 *      1920x1080_48fps
 *      1920x1080_60fps
 *      1280x720_24fps
 *      1280x720_30fps
 *      1280x720_48fps
 *      1280x720_60fps
 *
 *  @param resolution Resolution to be set for the video.
 *  @param rate       Frame rate to be set for the video.
 *  @param block      Remote execution result error block.
 */
- (void)setVideoResolution:(DJICameraVideoResolution)resolution andFrameRate:(DJICameraVideoFrameRate)rate withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's video resolution and frame rate values.
 *
 */
- (void)getVideoResolutionAndFrameRateWithCompletion:(void (^)(DJICameraVideoResolution resolution, DJICameraVideoFrameRate rate, NSError *_Nullable error))block;

/**
 *  Sets the camera's video file format. The default value is DJICameraVideoFileFormatMOV.
 *
 *  @param format Video file format to be set for videos.
 *  @param block  Remote execution result error block.
 */
- (void)setVideoFileFormat:(DJICameraVideoFileFormat)format withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's video file format.
 *
 *  @param block  Completion block to return the current video file format.
 */
- (void)getVideoFileFormatWithCompletion:(void (^)(DJICameraVideoFileFormat format, NSError *_Nullable error))block;

/**
 *  Sets the camera's analog video standard. Setting the video standard to PAL or NTSC will limit the available resolutions and frame rates to those compatible with the chosen video standard.
 *
 *  @param videoStandard    Video standard value to be set for the camera.
 *  @param result           Remote execution result error block.
 */
- (void)setVideoStandard:(DJICameraVideoStandard)videoStandard withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's video standard value.
 */
- (void)getVideoStandardWithCompletion:(void (^)(DJICameraVideoStandard videoStandard, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Photo related
//-----------------------------------------------------------------
/**
 *  Sets the camera's aspect ratio for photos. Check the enum named DJICameraPhotoAspectRatio
 *  in DJICameraSettingsDef.h to find all possible ratios.
 *
 *  @param ratio     Aspect ratio for photos to be taken by camera.
 *  @param block     Remote execution result error block.
 */
- (void)setPhotoRatio:(DJICameraPhotoAspectRatio)ratio withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's aspect ratio for photos.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getPhotoRatioWithCompletion:(void (^)(DJICameraPhotoAspectRatio ratio, NSError *_Nullable error))block;

/**
 *  Sets the camera's photo quality for JPEG images. Check the enum named DJICameraPhotoQuality in
 *  DJICameraSettingsDef.h to find all possible camera photo qualities.
 *
 *  @param quality Camera photo quality to set to.
 *  @param block   Remote execution result error block.
 */
- (void)setPhotoQuality:(DJICameraPhotoQuality)quality withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's photo quality.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getPhotoQualityWithCompletion:(void (^)(DJICameraPhotoQuality quality, NSError *_Nullable error))block;

/**
 *  Sets the camera's photo file format. Check the enum named DJICameraPhotoFileFormat in
 *  DJICameraSettingsDef.h to find all possible photo formats the camera can be set to.
 *
 *  @param photoFormat Photo file format used when the camera takes a photo.
 *  @param block       Completion block.
 */
- (void)setPhotoFileFormat:(DJICameraPhotoFileFormat)photoFormat withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's photo file format.
 *
 *  @param block Completion block.
 */
- (void)getPhotoFileFormatWithCompletion:(void (^)(DJICameraPhotoFileFormat photoFormat, NSError *_Nullable error))block;

/**
 *  Sets burst shoot count for the camera, for the case when the user wants to use burst shoot.
 *  Check the enum named DJICameraPhotoBurstCount in DJICameraSettingsDef.h to find all possible
 *  burst count values the camera can be set to.
 *
 *  @param count The number of photos to take in one burst shoot
 *  @param block Completion block.
 */
- (void)setPhotoBurstCount:(DJICameraPhotoBurstCount)count withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the burst count type.
 *
 *  @param block Completion block.
 */
- (void)getPhotoBurstCountWithCompletion:(void (^)(DJICameraPhotoBurstCount count, NSError *_Nullable error))block;

/**
 *  Sets the camera's AEB capture parameters.
 *
 *  @param aebParam AEB capture parameters to be set for the camera.
 *  @param block    Remote execution result error block.
 */
- (void)setPhotoAEBParam:(DJICameraPhotoAEBParam)aebParam withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's AEB capture parameters.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getPhotoAEBParamWithCompletion:(void (^)(DJICameraPhotoAEBParam aeb, NSError *_Nullable error))block;

/**
 *  Sets the interval shoot parameters. The camera will capture a photo, wait a specified interval of time,
 *  take another photo, and continue in this manner until it has taken the required number of photos.
 *
 *  @param count    The number of photos to capture. The value should fall in [2, 255]. If the value of
 *                  captureCount is set to 255, the camera will continue to take photos at the specified
 *                  interval until stopShootPhotoWithCompletion is called.
 *
 *  @param interval The time interval between when two photos are taken.
 *                  The range for this parameter depends the photo file format(DJICameraPhotoFileFormat).
 *                  When the file format is JPEG, the range is [2, 2^16-1] seconds.
 *                  When the file format is RAW or RAW+JPEG, the range is [10, 2^16-1] seconds.
 *                  Inspire PRO is an exception. The range for Inspire PRO is [5, 2^16-1] seconds for all formats.
 */
- (void)setPhotoIntervalParam:(DJICameraPhotoIntervalParam)param withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's interval shoot parameters.
 *
 *  @param block Completion block.
 */
- (void)getPhotoIntervalParamWithCompletion:(void (^)(DJICameraPhotoIntervalParam captureParam, NSError *_Nullable error))block;

/**
 *  Sets the TimeLapse parameters including interval, duration and file format when saving.
 *
 *  Precondition:
 *  Camera should be in TimeLapse mode of CameraShootPhotoMode.
 *  Supported only by OSMO.
 *
 *  @param interval     The time between image captures.
 *                      An integer falls in the range, [10, 8191]. The unit is 100ms. Please note that when
 *                      the format is JPEG+Video, the minimum interval is 20(2 seconds).
 *  @param duration     The time for the whole action. An integer falls in the range, [0, 2^31-1] seconds.
 *                      If the value is set to be 0, it means that it shoots forever until invoking
 *                      stopShootPhoto method.
 *  @param fileFormat   A enum type of the file format to be used.
 *                      Please refer to DJICameraPhotoTimeLapseFileFormat in DJICameraSettingsDef.
 *  @param block        The execution block with the execution result returned.
 *
 */
- (void)setPhotoTimeLapseInterval:(NSUInteger)interval duration:(NSUInteger)duration fileFormat:(DJICameraPhotoTimeLapseFileFormat)format withCompletion:(DJICompletionBlock)block;
/**
 *  Supported only by OSMO camera.
 *  Gets the TimeLapse parameters including interval, duration and file format when saving.
 *
 *  Precondition:
 *  Camera should be in TimeLapse mode of CameraPhotoShootMode.
 *
 *  @param block    The execution callback with the value(s) returned.
 */
- (void)getPhotoTimeLapseIntervalDurationAndFileFormatWithCompletion:(void (^)(NSUInteger interval, NSUInteger duration, DJICameraPhotoTimeLapseFileFormat format, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Exposure Settings
//-----------------------------------------------------------------

/**
 *  Sets the camera's exposure mode. Check the enum named DJICameraExposureMode in
 *  DJICameraSettingsDef.h to find all possible camera exposure modes.
 *
 *  @param mode  Camera exposure mode to set to.
 *  @param block Remote execution result error block.
 */
- (void)setExposureMode:(DJICameraExposureMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's exposure mode.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getExposureModeWithCompletion:(void (^)(DJICameraExposureMode, NSError *_Nullable))block;

/**
 *  Sets the camera's ISO value. Check the enum named DJICameraISO in
 *  DJICameraSettingsDef.h to find all possible ISO options that the camera can be set to.
 *
 *  For all cameras except X5 the ISO value can only be set when the camera exposure mode is Manual mode. For X5, the ISO value can be set for all modes. Refer to setExposureMode:withCompletion: method for how to set exposure mode.
 *
 *  @param iso ISO value to be set.
 *  @param block   Completion block.
 */
- (void)setISO:(DJICameraISO)iso withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's ISO value.
 *
 *  @param block Completion block.
 */
- (void)getISOWithCompletion:(void (^)(DJICameraISO iso, NSError *_Nullable error))block;

/**
 *  Sets the camera shutter speed. For all available values shutterSpeed can be set to, check the
 *  top of DJICameraSettingsDef.h.
 *
 *  The shutter speed should not be set slower than the video frame rate when the camera's mode is
 *  DJICameraModeRecordVideo. For example, if the video frame rate = 30fps, then the shutterSpeed must
 *  be <= 1/30.
 *
 *  Precondition: Shutter speed can be set only when the camera exposure mode is either Shutter mode or Manual mode.
 *
 *  @param shutterSpeed Shutter speed value to be set for the camera.
 *  @param block        Remote execution result error block.
 */
- (void)setShutterSpeed:(DJICameraShutterSpeed)shutterSpeed withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's shutter speed.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getShutterSpeedWithCompletion:(void (^)(DJICameraShutterSpeed shutterSpeed, NSError *_Nullable error))block;

/**
 *  Sets the camera's exposure metering. Check the enum named DJICameraMeteringMode in
 *  DJICameraSettingsDef.h to find all possible exposure metering the camera can be set to.
 *
 *  @param meteringType Exposure metering to be set.
 *  @param block        Completion block.
 */
- (void)setMeteringMode:(DJICameraMeteringMode)meteringType withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's exposure metering.
 *
 *  @param block Completion block.
 */
- (void)getMeteringModeWithCompletion:(void (^)(DJICameraMeteringMode exposureMetering, NSError *_Nullable error))block;

/**
 *  Sets the spot metering area index. The camera image is divided into 96 spots defined by 12 columns and 8 rows.
 *  The row index falls in [0,7] where the values increase top to bottom across the image. The column index falls
 *  in [0, 11], where the values increase left to right.
 *  In order to make the method work, The camera exposure mode should be 'Program', 'Shutter' or 'Aperture' and the
 *  exposure metering mode should be DJICameraMeteringModeSpot.
 *
 *  @param rowIndex  Spot metering area row index to be set.
 *  @param colIndex  Spot metering area column index to be set.
 *  @param block     Remote execution result error block.
 */
- (void)setSpotMeteringAreaRowIndex:(uint8_t)rowIndex andColIndex:(uint8_t)colIndex withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the spot metering area row index and column index.
 */
- (void)getSpotMeteringAreaRowIndexAndColIndexWithCompletion:(void (^)(uint8_t rowIndex, uint8_t colIndex, NSError *_Nullable error))block;

/**
 *  Sets the camera's exposure compensation. Check the enum named DJICameraExposureCompensation
 *  in DJICameraSettingsDef.h to find all possible exposure compensations the camera can be set to.
 *  In order to use this function, the camera exposure mode should be 'shutter', 'program' or 'aperture'.
 *
 *  @param compensationType Exposure compensation value to be set for the camera.
 *  @param block            Completion block.
 */
- (void)setExposureCompensation:(DJICameraExposureCompensation)compensationType withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's exposure compensation.
 *
 *  @param block Completion block.
 */
- (void)getExposureCompensationWithCompletion:(void (^)(DJICameraExposureCompensation exposureCompensation, NSError *_Nullable error))block;

/**
 *  Sets whether or not the camera's AE (auto exposure) lock is locked or not.
 *
 *  Post condition:
 *  If AE lock is enabled, spot metering area cannot be set.
 *
 *  @param isLock   YES if the camera AE lock is locked or unlocked.
 *  @param callback The execution callback with the execution result returned.
 */
- (void)setAELock:(BOOL)isLock withCompletion:(DJICompletionBlock)block;

/**
 *  Gets if the camera's AE (auto exposure) lock is locked or not.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getAELockWithCompletion:(void (^)(BOOL isLocked, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark White Balance
//-----------------------------------------------------------------

/**
 *  Sets the camera’s white balance and color temperature.
 *
 *  When the white balance is a preset value (values except CustomColorTemperature), the colorTemperature argument does not take effect. When the white balance is CustomColorTemperature, the colorTemperature value is used instead. Check the enum named DJICameraWhiteBalance in DJICameraSettingsDef.h to find all possible white balance options the camera can be set to.
 *
 *  @param whiteBalance     White balance value to be set.
 *  @param colorTemperature Color temperature value to be set in the range of [20, 100]. Real color temperature value(K) = value * 100. For example, 50 -> 5000K.
 *  @param block            Completion block.
 */
- (void)setWhiteBalance:(DJICameraWhiteBalance)whiteBalance andColorTemperature:(uint8_t)colorTemperature withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's white balance and color temperature.
 *
 *  @param block Completion block.
 */
- (void)getWhiteBalanceAndColorTemperatureWithCompletion:(void (^)(DJICameraWhiteBalance whiteBalance, uint8_t colorTemperature, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Other settings
//-----------------------------------------------------------------
/**
 *  Sets the camera's anti-flicker for video recording.
 *
 *  Precondition:
 *  Please make sure the exposure mode is Program.
 *
 *  @param antiFlickerType  Anti-flicker value to set for the camera. Please check the enum DJICameraAntiFlicker
 *                          to find all the possible anti-flicker type the camera can be set to.
 *  @param callback         The execution callback with the execution result returned.
 */
- (void)setAntiFlicker:(DJICameraAntiFlicker)antiFlickerType withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's anti-flicker.
 *
 *  @param block Completion block.
 */
- (void)getAntiFlickerWithCompletion:(void (^)(DJICameraAntiFlicker antiFlicker, NSError *_Nullable error))block;

/**
 *  Sets the camera's sharpness. Check the enum named DJICameraSharpness
 *  in DJICameraSettingsDef.h to find all possible sharpnesss the camera can be set to.
 *
 *  @param sharpness Sharpness value to be set for the camera.
 *  @param block     Completion block.
 */
- (void)setSharpness:(DJICameraSharpness)sharpness withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's sharpness.
 *
 *  @param block Completion block.
 */
- (void)getSharpnessWithCompletion:(void (^)(DJICameraSharpness sharpness, NSError *_Nullable error))block;

/**
 *  Sets the camera's contrast. Check the enum named DJICameraContrast
 *  in DJICameraSettingsDef.h to find all possible contrasts the camera can be set to.
 *
 *  @param contrast Contrast value to be set for the camera.
 *  @param block    Completion block.
 */
- (void)setContrast:(DJICameraContrast)contrast withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's contrast.
 *
 *  @param block Completion block.
 */
- (void)getContrastWithCompletion:(void (^)(DJICameraContrast contrast, NSError *_Nullable error))block;

/**
 *  Sets the camera's saturation. The default value of the saturation value is 0.
 *
 *  @param saturation Saturation value to be set in the range of [-3, 3].
 *  @param block      Remote execution result error block.
 */
- (void)setSaturation:(int8_t)saturation withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's saturation.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getSaturationWithCompletion:(void (^)(int8_t saturation, NSError *_Nullable error))block;

/**
 *  Sets the camera's hue. The default value of the saturation value is 0.
 *
 *  @param hue   Hue value to be set in the range of [-3, 3].
 *  @param block Remote execution result error block.
 */
- (void)setHue:(int8_t)hue withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's hue.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getHueWithCompletion:(void (^)(int8_t hue, NSError *_Nullable error))block;

/**
 *  Sets the camera's digital filter. The default value is DJICameraDigitalFilterNone.
 *  For a list of all possible camera digital filters, check the enum named DJICameraDigitalFilter in
 *  DJICameraSettingsDef.h.
 *
 *  @param filter Digital filter to be set to the camera.
 *  @param block  Remote execution result error block.
 */
- (void)setDigitalFilter:(DJICameraDigitalFilter)filter withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's digital filter.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getDigitalFilterWithCompletion:(void (^)(DJICameraDigitalFilter filter, NSError *_Nullable error))block;

/**
 *  Returns whether or not the device supports quick view. Quick view is an amount of time a photo is shown as a preview after it is taken and before the camera returns back to the live camera view.
 *  seconds.
 */
- (BOOL)isPhotoQuickViewSupported;

/**
 *  Sets the camera's quick view duration. The valid range is [0, 10] seconds. When duration is 0, it means that the quick view
 *  is disabled. The default value is 0 second.
 *  It is not supported by Phantom 3 Standard. Please check isPhotoQuickViewSupported before using this method.
 *
 *  @param duration Quick view duration to be set for the camera.
 *  @param block    Remote execution result error block.
 */
- (void)setPhotoQuickViewDuration:(NSUInteger)duration withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's quick view duration.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getPhotoQuickViewDurationWithCompletion:(void (^)(NSUInteger duration, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Audio Settings
//-----------------------------------------------------------------
/**
 *  Check if the current device supports audio recording.
 *  Currently audio recording is supported only by the OSMO camera.
 */
- (BOOL)isAudioRecordSupported;

/**
 *  Enables audio recording when capturing video.
 *  Supported only by OSMO camera.
 *
 *  @param enabled   Enable or disable audio recording.
 *  @param block     The execution callback with the execution result returned.
 *
 */
- (void)setAudioRecordEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Supported only by OSMO camera.
 *  Gets whether the audio record is enabled or not.
 *
 *  @param block    The execution callback with the value(s) returned.
 */
- (void)getAudioRecordEnabledWithCompletion:(void (^)(BOOL enabled, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Advanced Camera Settings
//-----------------------------------------------------------------
/**
 *  Gets whether the changeable lens is supported by the camera.
 *  Currently, a changeable lens is supported only by X5 camera.
 */
- (BOOL)isChangeableLensSupported;
/**
 *  Gets details of the installed lens.
 *  Supported only by X5 camera.
 *  It is available only when isChangeableLensSupported returns YES.
 *
 *  @param callback The execution callback with the value(s) returned.
 */
- (void)getLensInformationWithCompletion:(void (^)(NSString *_Nullable info, NSError *_Nullable error))block;

/**
 *  Gets whether the camera supports an adjustable aperture.
 *  Currently, adjustable aperture is supported only by X5 camera.
 */
- (BOOL)isAdjustableApertureSupported;

/**
 *  Sets the aperture value.
 *  It is available only when isAdjustableApertureSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  Precondition:
 *  The exposure mode should be in Manual or AperturePriority.
 *
 *  @param aperture The aperture to set. Check enum CameraLensFocusMode in DJICameraSettingsDef.
 *  @param block    The execution callback with the execution result returned.
 */
- (void)setAperture:(DJICameraAperture)aperture withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens aperture.
 *  It is available only when isAdjustableApertureSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param block The execution callback with the value(s) returned.
 */
- (void)getApertureWithCompletion:(void (^)(DJICameraAperture aperture, NSError *_Nullable error))block;

/**
 *  Gets whether the camera supports an adjustable focal point.
 *  Currently, adjustable focal point is supported only by X5 camera.
 */
- (BOOL)isAdjustableFocalPointSupported;

/**
 *  Sets the lens focus mode. Check enum CameraLensFocusMode in DJICameraSettingsDef.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param focusMode    Focus mode to set. Please refer to DJICameraLensFocusMode for more detail.
 *  @param block        The execution callback with the execution result returned.
 */
- (void)setLensFocusMode:(DJICameraLensFocusMode)focusMode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens focus mode. Please check enum CameraLensFocusMode in DJICameraSettingsDef.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 * @param block The execution callback with the value(s) returned.
 */
- (void)getLensFocusModeWithCompletion:(void (^)(DJICameraLensFocusMode focusMode, NSError *_Nullable error))block;

/**
 *  Sets the lens focus Target point.
 *  When the focus mode is auto, the target point is the focal point.
 *  When the focus mode is manual, the target point is the zoom out area if the focus assistant is enabled for
 *  the manual mode.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param focusTarget  The focus target to set. The range for x and y is from 0.0 to 1.0. The point [0.0, 0.0]
 *                      represents the top-left angle of the screen.
 *  @param block        The execution callback with the execution result returned.
 *
 */
- (void)setLensFocusTarget:(CGPoint)focusTarget withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens focus Target point.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param callback The execution callback with the value(s) returned.
 */
- (void)getLensFocusTargetWithCompletion:(void (^)(CGPoint focusTarget, NSError *_Nullable error))block;

/**
 *  Sets whether the lens focus assistant is enabled or not.
 *  If the focus assistant is enabled, a specific area of the screen will zoom out during focusing.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param enabledMF    Sets whether the lens focus assistant under MF mode is enabled or not.
 *  @param enabledAF    Sets whether the lens focus assistant under AF mode is enabled or not.
 *  @param block        The execution callback with the execution result returned.
 */
- (void)setLensFocusAssistantEnabledForMF:(BOOL)MFenabled andAF:(BOOL)AFenabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether the lens focus assistant is enabled or not.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param block The execution callback with the value(s) returned.
 *  The first result stands for MF, the second result stands for AF.
 */
- (void)getLensFocusAssistantEnabledForMFAndAFWithCompletion:(void (^)(BOOL MFenabled, BOOL AFenabled, NSError *_Nullable error))block;

/**
 *  Gets the lens focusing ring value's max value.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param callback The execution callback with the value(s) returned.
 */
- (void)getLensFocusRingValueUpperBoundWithCompletion:(void (^)(NSUInteger upperBound, NSError *_Nullable error))block;

/**
 *  Set the focal distance by simulating the focus ring adjustment. Value can have a range of [0, getLensFocusRingValueUpperBoundWithCompletion] which represents the closest possible focal distance and infinity.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param value    An integer value to adjust the focusing ring.
 *                  The minimum value is 0, the maximum value depends on the installed lens. Please use method
 *                  getLensFocusRingValueUpperBoundWithCompletion to ensure the input argument is valid.
 *  @param block    The execution callback with the execution result returned.
 *
 */
- (void)setLensFocusRingValue:(NSUInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets lens focus ring value.
 *  It is available only when isAdjustableFocalPointSupported returns YES.
 *  Supported only by X5 camera.
 *
 *  @param callback The execution callback with the value(s) returned.
 */
- (void)getLensFocusRingValueWithCompletion:(void (^)(NSUInteger distance, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Save/load camera settings
//-----------------------------------------------------------------
/**
 *  Load the camera's factory settings. <br>
 *
 *  Post condition:
 *  The camera will reboot itself.
 *
 *  @param callback The execution callback with the execution result returned.
 */
- (void)loadFactorySettings:(DJICompletionBlock)block;

/**
 *  Saves the current camera settings permanently to the specified user. Check the enum named DJICameraCustomSettings in
 *  DJICameraSettingsDef.h to find all possible camera users.
 *
 *  @param settings Camera user to store camera settings to.
 *  @param result   Remote execution result error block.
 */
- (void)saveSettingsTo:(DJICameraCustomSettings)settings withCompletion:(DJICompletionBlock)block;

/**
 *  Load camera settings from the specified user.
 *
 *  @param settings Camera user to load camera settings from.
 *  @param result   Remote execution result error block.
 */
- (void)loadSettingsFrom:(DJICameraCustomSettings)settings withCompletion:(DJICompletionBlock)block;

@end

/*********************************************************************************/
#pragma mark - DJICamera (Media)
/*********************************************************************************/

@interface DJICamera (Media)
/**
 *  Check if the current device support Media Download Mode
 */
- (BOOL)isMediaDownloadModeSupported;

@end

/*********************************************************************************/
#pragma mark - DJICamera (CameraPlayback)
/*********************************************************************************/

@interface DJICamera (CameraPlayback)

/**
 *  Check if the current device supports Playback Mode
 */
- (BOOL)isPlaybackSupported;

@end

/*********************************************************************************/
#pragma mark - DJISDCardOperations
/*********************************************************************************/

@interface DJICamera (SDCardOperations)

/**
 *  Formats the SD card by deleting all the data on the SD card. This
 *  does not change any settings the user may have set on the SD card.
 */
- (void)formatSDCardWithCompletion:(DJICompletionBlock)block;

/**
 *  Gets the current state of the SD card. For instance, accessing the sdInfo
 *  parameter of the block will tell you whether or not the SD card is inserted
 *  into the camera or how much memory is remaining. For more information on all
 *  possible current states of the SD card, refer to DJICameraSDCardState.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getSDCardInfoWithCompletion:(void (^)(DJICameraSDCardState *_Nullable sdInfo, NSError *_Nullable error))block;

@end


NS_ASSUME_NONNULL_END
