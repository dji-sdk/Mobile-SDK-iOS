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
#import <DJISDK/DJICameraSSDState.h>
#import <DJISDK/DJICameraSettingsDef.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIMedia;
@class DJICamera;
@class DJICameraSystemState;
@class DJICameraSDCardState;
@class DJICameraPlaybackState;
@class DJICameraLensState;
@class DJIMediaManager;
@class DJIPlaybackManager;
@class UIImage;

/**
 *  Define the upper bound for thermal brightness setting
 */
#define DJI_THERMAL_BRIGHTNESS_UPPER_BOUND (16383)

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
- (void)camera:(DJICamera *_Nonnull)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size;

/**
 *  Updates the camera's current state.
 *
 *  @param camera      Camera that updates the current state.
 *  @param systemState The camera's system state.
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateSystemState:(DJICameraSystemState *_Nonnull)systemState;

/**
 *  Tells the delegate that the lens information is updated.
 *  This method is available only when `isChangeableLensSupported` is YES.
 *
 *  @param camera      Camera that sends out the updatd lens information.
 *  @param lensState   The camera's lens state.
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateLensState:(DJICameraLensState *_Nonnull)lensState;

/**
 *  Tells the delegate that a new media file (photo or video) has been generated.
 *
 *  @param camera   Camera that generates the new media file.
 *  @param newMedia The new media file.
 *
 *  @warning In this delegate, the `DJIMedia` instance properties `thumbnail` and `durationInSeconds` require special consideration. The `thumbnail` property normally has a pointer to a `UIImage` of the thumbnail, but this is only available when the camera is in `DJICameraModeMediaDownload` work mode. Additionally, for this instance of `DJIMedia`, the `durationInSeconds` property is 0.
 */
- (void)camera:(DJICamera *_Nonnull)camera didGenerateNewMediaFile:(DJIMedia *_Nonnull)newMedia;

/**
 *  Tells the delegate that a time-lapse preview image has been generated.
 *  This method is only available on Osmo with the upcoming firmware version.
 *
 *  @param camera       Camera that generates the time-lapse preview image.
 *  @param previewImage The new generated preview image.
 */
- (void)camera:(DJICamera *_Nonnull)camera didGenerateTimeLapsePreview:(UIImage *_Nonnull)previewImage;

/**
 *  Tells the delegate that the camera's SD card state has been updated.
 *
 *  @param camera       Camera that sends out the updated SD card state.
 *  @param sdCardState  The camera's SD card state.
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateSDCardState:(DJICameraSDCardState *_Nonnull)sdCardState;

/**
 *  Tells the delegate that the camera's SSD state has been updated.
 *  This method is available only when isSSDSupported is YES.
 *
 *  @param camera   Camera that sends out the updated SSD state.
 *  @param ssdState The camera's SSD state.
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateSSDState:(DJICameraSSDState *_Nonnull)ssdState;

/**
 *  Called when there are new min, max, and average values available for the set spot metering area. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param camera                  Camera that sends out the aggregate temperature values
 *  @param temperatureAggregations The updated aggregate temperature values
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateAreaTemperatureAggregations:(DJICameraThermalAreaTemperatureAggregations)temperatureAggregations;

/**
 *  Called when updated external scene settings are available. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param camera                Camera that sends out the external scene setting values
 *  @param externalSceneSettings The updated external scene settings values
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateExternalSceneSettings:(DJICameraThermalExternalSceneSettings)externalSceneSettings;

/**
 *  Called whenever the camera parameters change. In automatic exposure modes
 *  (Program, Shutter Priority and Aperture Priority) the camera may be
 *  automatically changing aperture, shutter speed and ISO (depending on the
 *  mode and camera) when lighting conditions change. In Manual mode, the
 *  exposure compensation is automatically updated to let the user know how much
 *  compensation the exposure needs to get to an exposure the camera calculates
 *  as correct.
 *
 *  @param camera   Camera that sends out the video data.
 *  @param params   The updated real values for parameters.
 *
 *  @see DJICameraExposureParameters
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateCurrentExposureParameters:(DJICameraExposureParameters)params;

/**
 *  Received temperature in degrees Celsius of image. The thermal imaging camera
 *  will only update the temperature if the temperature data is enabled.
 *  For the XT Standard version, the temperature measurement data is the average
 *  of the center four pixels of the image.
 *  For the XT Advanced Radiometry version, the temperature measurement point
 *  can be set using `setThermalSpotMeteringTargetPoint:withCompletion`.
 *
 *  @param camera   Camera that sends out the updated center temperature.
 *  @param temperature The camera's temperature data in degrees Celsius.
 *  @see [- (void)setThermalTemperatureDataEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block].
 */
- (void)camera:(DJICamera *_Nonnull)camera didUpdateTemperatureData:(float)temperature;

@end

/*********************************************************************************/
#pragma mark - DJICamera
/*********************************************************************************/

/**
 *  This class contains the media manager and playback manager to manage the
 *  Camera's media content. It provides methods to change camera settings and
 *  perform camera actions.
 *
 */
@interface DJICamera : DJIBaseComponent

/**
 *  Delegate that recevies the information sent by the camera.
 */
@property(nonatomic, weak) id<DJICameraDelegate> delegate;

/**
 *  String that represents name of the camera.
 */
@property(nonatomic, readonly) NSString *_Nonnull displayName;

/**
 *  Media Manager is used for interaction when camera is in `DJICameraModeMediaDownload`.
 *  The user can only access the manager when `isMediaDownloadModeSupported` returns `YES`.
 */
@property(nonatomic, readonly) DJIMediaManager *_Nullable mediaManager;

/**
 *  Playback Manager is used for interaction when camera is in `DJICameraModePlayback`.
 *  User can only access to the manager when isPlaybackSupported returns YES.
 */
@property(nonatomic, readonly) DJIPlaybackManager *_Nullable playbackManager;

/*********************************************************************************/
#pragma mark Camera work mode
/*********************************************************************************/

/**
 *  Sets the camera's work mode to taking pictures, video, playback or download
 *  (see [DJICameraMode](../Enums/DJICameraMode.html)) for details on camera
 *  work modes. Note that you cannot change the mode when a certain task is
 *  executing, such as taking photo(s), recording video, or downloading and
 *  saving files.
 *  Also supported by thermal imaging camera.
 *
 *  @param mode  Camera work mode.
 *  @param block Remote execution result error block.
 */
- (void)setCameraMode:(DJICameraMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's current work mode.
 *  Also supported by thermal imaging camera.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCameraModeWithCompletion:(void (^_Nonnull)(DJICameraMode, NSError *_Nullable))block;

/*********************************************************************************/
#pragma mark Shoot photos
/*********************************************************************************/

/**
 *  Check if the current device supports time-lapse shoot mode.
 *  Supported only on the Osmo camera.
 */
- (BOOL)isTimeLapseSupported;

/**
 *  Camera starts to take photo with one of the camera capture modes (shoot
 *  photo modes).
 *
 *  Preconditions:
 *
 *  1. Camera must be in ShootPhoto mode.
 *  2. The SD card state should be checked before this method is used to ensure
 *     sufficient space exists.
 *
 *
 *  Note that if the capture mode is Interval or Time-lapse, calling
 *  `stopShootPhoto` may be required for the camera to stop taking photos.
 *  Also supported by thermal imaging camera.
 *
 *  @param shootMode  Shoot photo mode with which the camera can start taking
 *                    photos. See [CameraShootPhotoMode](../Enums/CameraShootPhotoMode.html)
 *                    to view all possible camera shoot modes.
 *  @param block      The execution callback with the returned execution result.
 */
- (void)startShootPhoto:(DJICameraShootPhotoMode)shootMode withCompletion:(DJICompletionBlock)block;

/**
 *  Camera stops taking photos.
 *
 *  Preconditions:
 *
 *  1. `startShootPhoto:withCompletion:` has been invoked and the shoot mode is
 *     either Interval or Time-lapse.
 *  2. The shoot photo operation is still executing.
 *
 *
 *  Also supported by thermal imaging camera.
 *
 *  @param block The execution callback with the returned execution result.
 */
- (void)stopShootPhotoWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Record video
/*********************************************************************************/

/**
 *  `YES` if current device supports Slow Motion video recording.
 *  Currently Slow Motion is supported only by the Osmo camera and the Phantom 4
 *  camera. There are two ways to enter Slow Motion mode:
 *
 *  1. Call `setVideoSlowMotionEnabled:withCompletion:` with YES.
 *  2. Call `setVideoResolution:andFrameRate:withCompletion:` with
 *     `DJICameraVideoResolution1920x1080` and `DJICameraVideoFrameRate120fps`.
 *
 */
- (BOOL)isSlowMotionSupported;

/**
 *  Enables/Disables Slow Motion video recording.
 *  When it is enabled, the resolution and frame rate will change to 1920x1080
 *  120fps.
 *  When it is disabled, the resolution and frame rate will revert to the
 *  previous setting for Osmo, while for the Phantom 4 camera, the resolution
 *  will remain at `DJICameraVideoResolution1920x1080` and the frame rate will
 *  change to `DJICameraVideoFrameRate48fps`.
 *
 *  @param enabled  Enable or disable Slow Motion video.
 *  @param block    The execution callback with the returned execution result.
 */
- (void)setVideoSlowMotionEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Determines whether Slow Motion mode is enabled.
 *  Supported only by the Osmo camera.
 *
 *  @param block The execution callback with the returned value(s).
 */
- (void)getVideoSlowMotionEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Starts recording video. The camera must be in `DJICameraModeRecordVideo`
 *  work mode.
 *  Also supported by thermal imaging camera.
 */
- (void)startRecordVideoWithCompletion:(DJICompletionBlock)block;

/**
 *  Stops recording video.
 *  Also supported by thermal imaging camera.
 */
- (void)stopRecordVideoWithCompletion:(DJICompletionBlock)block;

@end

/*********************************************************************************/
#pragma mark - DJICamera (CameraSettings)
/*********************************************************************************/

@interface DJICamera (CameraSettings)

/*********************************************************************************/
#pragma mark Camera basic settings
/*********************************************************************************/

/**
 *  Sets the camera's file index mode for the SD card. The default value of
 *  `DJICameraFileIndexMode` is set to `DJICameraFileIndexModeReset`.
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
- (void)getFileIndexModeWithCompletion:(void (^_Nonnull)(DJICameraFileIndexMode fileIndex, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Video related
/*********************************************************************************/

/**
 *  Sets the camera's video resolution and frame rate.
 *  @warning The supported resolutions and frame rates for the two different
 *  analog television standards PAL and NSTC are below:<br/><br/>
 *       <b>NTSC:</b><br/> Resolution_4096x2160, FrameRate_24fps<br/>
 *             Resolution_3840x2160, FrameRate_30fps<br/>
 *             Resolution_3840x2160, FrameRate_24fps<br/>
 *             Resolution_2704X1520, FrameRate_30fps<br/>
 *             Resolution_2704X1520, FrameRate_24fps<br/>
 *             Resolution_1920x1080, FrameRate_120fps (Slow Motion)<br/>
 *             Resolution_1920x1080, FrameRate_60fps<br/>
 *             Resolution_1920x1080, FrameRate_48fps<br/>
 *             Resolution_1920x1080, FrameRate_30fps<br/>
 *             Resolution_1920x1080, FrameRate_24fps<br/>
 *             Resolution_1280x720, FrameRate_60fps<br/>
 *             Resolution_1280x720, FrameRate_48fps<br/>
 *             Resolution_1280x720, FrameRate_30fps<br/>
 *             Resolution_1280x720, FrameRate_24fps<br/><br/>
 *       <br/><br/>
 *       <b>PAL:</b><br/> Resolution_4096x2160, FrameRate_25fps<br/>
 *             Resolution_4096x2160, FrameRate_24fps<br/>
 *             Resolution_3840x2160, FrameRate_25fps<br/>
 *             Resolution_3840x2160, FrameRate_24fps<br/>
 *             Resolution_2704X1520, FrameRate_25fps<br/>
 *             Resolution_2704X1520, FrameRate_24fps<br/>
 *             Resolution_1920x1080, FrameRate_120fps (Slow Motion)<br/>
 *             Resolution_1920x1080, FrameRate_50fps<br/>
 *             Resolution_1920x1080, FrameRate_48fps<br/>
 *             Resolution_1920x1080, FrameRate_25fps<br/>
 *             Resolution_1920x1080, FrameRate_24fps<br/>
 *             Resolution_1280x720, FrameRate_50fps<br/>
 *             Resolution_1280x720, FrameRate_48fps<br/>
 *             Resolution_1280x720, FrameRate_25fps<br/>
 *             Resolution_1280x720, FrameRate_24fps<br/><br/>
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
- (void)getVideoResolutionAndFrameRateWithCompletion:(void (^_Nonnull)(DJICameraVideoResolution resolution, DJICameraVideoFrameRate rate, NSError *_Nullable error))block;

/**
 *  Sets the camera's video file format. The default value is `DJICameraVideoFileFormatMOV`.
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
- (void)getVideoFileFormatWithCompletion:(void (^_Nonnull)(DJICameraVideoFileFormat format, NSError *_Nullable error))block;

/**
 *  Sets the camera's analog video standard. Setting the video standard to PAL
 *  or NTSC will limit the available resolutions and frame rates to those
 *  compatible with the chosen video standard.
 *  Also supported by thermal imaging camera.
 *
 *  @param videoStandard    Video standard value to be set for the camera.
 *  @param result           Remote execution result error block.
 */
- (void)setVideoStandard:(DJICameraVideoStandard)videoStandard withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's video standard value.
 *  Also supported by thermal imaging camera.
 */
- (void)getVideoStandardWithCompletion:(void (^_Nonnull)(DJICameraVideoStandard videoStandard, NSError *_Nullable error))block;

/**
 * Enables recording position, time and camera information into a video caption file (.srt) saved on the SD card.
 * The information is updated at 1Hz. Currently the .srt file can only be downloaded directly from the SD card.
 *
 * @param enabled   `YES` to enable video caption.
 * @param block     The execution callback with the returned value.
 */
- (void)setVideoCaptionEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Gets whether the video caption is enabled.
 *
 *  @param block    The completion block with the returned value(s).
 */
- (void)getVideoCaptionEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Photo related
/*********************************************************************************/

/**
 *  Sets the camera's aspect ratio for photos. See [DJICameraPhotoAspectRatio](../Enums/DJICameraPhotoAspectRatio.html) to view all possible ratios.
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
- (void)getPhotoRatioWithCompletion:(void (^_Nonnull)(DJICameraPhotoAspectRatio ratio, NSError *_Nullable error))block;

/**
 *  Sets the camera's photo quality for JPEG images. See [DJICameraPhotoQuality](../Enums/DJICameraPhotoQuality.html) to view all possible camera photo qualities.
 *
 *  @param quality Camera photo quality to set.
 *  @param block   Remote execution result error block.
 */
- (void)setPhotoQuality:(DJICameraPhotoQuality)quality withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's photo quality.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getPhotoQualityWithCompletion:(void (^_Nonnull)(DJICameraPhotoQuality quality, NSError *_Nullable error))block;

/**
 *  Sets the camera's photo file format. See [DJICameraPhotoFileFormat](../Enums/DJICameraPhotoFileFormat.html) to view all possible photo formats to which the camera can be set.
 *  Also supported by thermal imaging camera.
 *
 *  @param photoFormat Photo file format used when the camera takes a photo.
 *  @param block       Completion block.
 */
- (void)setPhotoFileFormat:(DJICameraPhotoFileFormat)photoFormat withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's photo file format.
 * Also supported by thermal imaging camera.
 *
 *  @param block Completion block.
 */
- (void)getPhotoFileFormatWithCompletion:(void (^_Nonnull)(DJICameraPhotoFileFormat photoFormat, NSError *_Nullable error))block;

/**
 *  Sets the burst shoot count for the camera when the user wants to use that feature.
 *  See [DJICameraPhotoBurstCount](../Enums/DJICameraPhotoBurstCount.html) to view all possible
 *  burst count values to which the camera can be set.
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
- (void)getPhotoBurstCountWithCompletion:(void (^_Nonnull)(DJICameraPhotoBurstCount count, NSError *_Nullable error))block;

/**
 *  Sets the camera's auto exposure bracketing (AEB) capture parameters.
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
- (void)getPhotoAEBParamWithCompletion:(void (^_Nonnull)(DJICameraPhotoAEBParam aeb, NSError *_Nullable error))block;

/**
 *  Sets the interval shoot parameters. The camera will capture a photo, wait a specified interval of time,
 *  take another photo, and continue in this manner until it has taken the required number of photos.
 *  Also supported by thermal imaging camera.
 *
 *  @param count    The number of photos to capture. The range is [2, 255]. If the value of
 *                  `captureCount` is set to `255`, the camera will continue to take photos at the specified
 *                  interval until `stopShootPhotoWithCompletion` is called.
 *
 *  @param interval The time interval during which two photos are taken.
 *                  The range for this parameter depends on the photo file format (`DJICameraPhotoFileFormat`).
 *                  For X5 and X5R, the range is [5, 2^16 - 1] seconds for all formats.
 *                  For XT, the range is [1, 60] seconds for all formats.
 *                  For other products, when the file format is JPEG, the range is [2, 2^16 - 1] seconds; when the file format is RAW or RAW+JPEG, the range is [10, 2^16 - 1] seconds.
 */
- (void)setPhotoIntervalParam:(DJICameraPhotoIntervalParam)param withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's interval shoot parameters.
 *  Also supported by thermal imaging camera.
 *
 *  @param block Completion block.
 */
- (void)getPhotoIntervalParamWithCompletion:(void (^_Nonnull)(DJICameraPhotoIntervalParam captureParam, NSError *_Nullable error))block;

/**
 *  Sets the TimeLapse parameters, including interval, duration and file format when saving.
 *
 *  Precondition:
 *  Camera should be in `TimeLapse` mode of `CameraShootPhotoMode`.
 *  Supported only by Osmo.
 *
 *  @param interval     The time between image captures.
 *                      An integer falls in the range, [10, 1000]. The unit is 100ms. Please note that when
 *                      the format is JPEG+Video, the minimum interval is 20(2 seconds).
 *  @param duration     The time for the whole action. An integer falls in the range, [0, 2^31-1] seconds.
 *                      If the value is set to be 0, it means that it shoots forever until invoking
 *                      stopShootPhoto method.
 *  @param fileFormat   A enum type of the file format to be used.
 *                      Please refer to DJICameraPhotoTimeLapseFileFormat in DJICameraSettingsDef.
 *  @param block        The execution block with the returned execution result.
 *
 */
- (void)setPhotoTimeLapseInterval:(NSUInteger)interval duration:(NSUInteger)duration fileFormat:(DJICameraPhotoTimeLapseFileFormat)format withCompletion:(DJICompletionBlock)block;
/**
 *  Supported only by Osmo camera.
 *  Gets the TimeLapse parameters including interval, duration and file format when saving.
 *
 *  Precondition:
 *  The camera must be in `TimeLapse` mode of `CameraPhotoShootMode`.
 *
 *  @param block    The execution callback with the returned value(s).
 */
- (void)getPhotoTimeLapseIntervalDurationAndFileFormatWithCompletion:(void (^_Nonnull)(NSUInteger interval, NSUInteger duration, DJICameraPhotoTimeLapseFileFormat format, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Exposure Settings
/*********************************************************************************/

/**
 *  Sets the camera's exposure mode. See [DJICameraExposureMode](../Enums/DJICameraExposureMode.html) to view all possible camera exposure modes.
 *
 *  @param mode  Camera exposure mode to set.
 *  @param block Remote execution result error block.
 */
- (void)setExposureMode:(DJICameraExposureMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's exposure mode.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getExposureModeWithCompletion:(void (^_Nonnull)(DJICameraExposureMode, NSError *_Nullable))block;

/**
 *  Sets the camera's ISO value. See [DJICameraISO](../Enums/DJICameraISO.html) to view all possible ISO settings for the camera.
 *
 *  For all cameras except the X5 and X5R, the ISO value can only be set when the camera exposure mode is in Manual mode. For the X5 and X5R, the ISO value can be set for all modes. See the `setExposureMode:withCompletion:` method for how to set exposure mode.
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
- (void)getISOWithCompletion:(void (^_Nonnull)(DJICameraISO iso, NSError *_Nullable error))block;

/**
 *  Sets the camera shutter speed. To see all available `shutterSpeed` value settings, see `DJICameraShutterSpeed`.

 *  The shutter speed should not be set slower than the video frame rate when the camera's mode is
 *  `DJICameraModeRecordVideo`. For example, if the video frame rate is 30fps, the `shutterSpeed` must
 *  be <= 1/30.
 *
 *  Precondition: The shutter speed can be set only when the camera exposure mode is Shutter mode or Manual mode.
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
- (void)getShutterSpeedWithCompletion:(void (^_Nonnull)(DJICameraShutterSpeed shutterSpeed, NSError *_Nullable error))block;

/**
 *  Sets the camera's exposure metering. See [DJICameraMeteringMode](../Enums/DJICameraMeteringMode.html) to view all possible exposure metering settings for the camera.
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
- (void)getMeteringModeWithCompletion:(void (^_Nonnull)(DJICameraMeteringMode exposureMetering, NSError *_Nullable error))block;

/**
 *  Sets the spot metering area index. The camera image is divided into 96 spots defined by 12 columns and 8 rows.
 *  The row index range is [0,7], where the values increase top to bottom across the image. The column index range is [0, 11], where the values increase left to right.
 *  In order to make the method work, The camera exposure mode should be 'Program', 'Shutter' or 'Aperture', the
 *  exposure metering mode must be `DJICameraMeteringModeSpot`, and `AELock` must be `NO`.
 *
 *  @param rowIndex  Spot metering area row index to be set.
 *  @param colIndex  Spot metering area column index to be set.
 *  @param block     Remote execution result error block.
 */
- (void)setSpotMeteringAreaRowIndex:(uint8_t)rowIndex andColIndex:(uint8_t)colIndex withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the spot metering area row index and column index.
 *  In order to make the method work, The camera exposure mode should be 'Program', 'Shutter' or 'Aperture', the
 *  exposure metering mode must be `DJICameraMeteringModeSpot`, and `AELock` must be `NO`.
 */
- (void)getSpotMeteringAreaRowIndexAndColIndexWithCompletion:(void (^_Nonnull)(uint8_t rowIndex, uint8_t colIndex, NSError *_Nullable error))block;

/**
 *  Sets the camera's exposure compensation. See [DJICameraExposureCompensation](../Enums/DJICameraExposureCompensation.html) to view all possible exposure compensations to which the camera can be set.
 *  In order to use this function, set the camera exposure mode to 'shutter', 'program' or 'aperture'.
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
- (void)getExposureCompensationWithCompletion:(void (^_Nonnull)(DJICameraExposureCompensation exposureCompensation, NSError *_Nullable error))block;

/**
 *  Locks or unlocks the camera's AE (auto exposure).
 *
 *  Post condition:
 *  If the AE lock is enabled, the spot metering area cannot be set.
 *
 *  @param isLock   `YES` if the camera AE is locked, `NO` if it is unlocked.
 *  @param callback The execution callback with the returned execution result.
 */
- (void)setAELock:(BOOL)isLock withCompletion:(DJICompletionBlock)block;

/**
 *  Determines if the camera's AE (auto exposure) is locked.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getAELockWithCompletion:(void (^_Nonnull)(BOOL isLocked, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark White Balance
/*********************************************************************************/

/**
 *  Sets the camera’s white balance and color temperature.
 *
 *  When the white balance is a preset value (values except `CustomColorTemperature`), the `colorTemperature` argument does not take effect. When the white balance is `CustomColorTemperature`, the `colorTemperature` value is used instead. See [DJICameraWhiteBalance](../Enums/DJICameraWhiteBalance.html) to view all possible white balance setting options for the camera.
 *
 *  @param whiteBalance     White balance value to be set.
 *  @param colorTemperature Color temperature value to be set in the range of [20, 100]. Real color temperature value (K) = value * 100. For example, 50 -> 5000K.
 *  @param block            Completion block.
 */
- (void)setWhiteBalance:(DJICameraWhiteBalance)whiteBalance andColorTemperature:(uint8_t)colorTemperature withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's white balance and color temperature.
 *
 *  @param block Completion block.
 */
- (void)getWhiteBalanceAndColorTemperatureWithCompletion:(void (^_Nonnull)(DJICameraWhiteBalance whiteBalance, uint8_t colorTemperature, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Other settings
/*********************************************************************************/

/**
 *  Sets the camera's anti-flicker for video recording.
 *
 *  Precondition:
 *  The exposure mode must be Program.
 *
 *  @param antiFlickerType  Anti-flicker value to set for the camera. See [DJICameraAntiFlicker](../Enums/DJICameraAntiFlicker.html) to view all the possible anti-flicker type settings for the camera.
 *  @param callback         The execution callback with the returned execution result.
 */
- (void)setAntiFlicker:(DJICameraAntiFlicker)antiFlickerType withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the camera's anti-flicker.
 *
 *  @param block Completion block.
 */
- (void)getAntiFlickerWithCompletion:(void (^_Nonnull)(DJICameraAntiFlicker antiFlicker, NSError *_Nullable error))block;

/**
 *  Sets the camera's sharpness. See [DJICameraSharpness](../Enums/DJICameraSharpness.html) to view all possible sharpnesss settings for the camera.
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
- (void)getSharpnessWithCompletion:(void (^_Nonnull)(DJICameraSharpness sharpness, NSError *_Nullable error))block;

/**
 *  Sets the camera's contrast. See [DJICameraContrast](../Enums/DJICameraContrast.html) to view all possible contrasts to which the camera can be set.
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
- (void)getContrastWithCompletion:(void (^_Nonnull)(DJICameraContrast contrast, NSError *_Nullable error))block;

/**
 *  Sets the camera's saturation. The default saturation value is 0.
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
- (void)getSaturationWithCompletion:(void (^_Nonnull)(int8_t saturation, NSError *_Nullable error))block;

/**
 *  Sets the camera's hue. The default hue value is 0.
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
- (void)getHueWithCompletion:(void (^_Nonnull)(int8_t hue, NSError *_Nullable error))block;

/**
 *  Sets the camera's digital filter. The default value is `DJICameraDigitalFilterNone`.
 *  For a list of all possible camera digital filters, see [DJICameraDigitalFilter](../Enums/DJICameraDigitalFilter.html).
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
- (void)getDigitalFilterWithCompletion:(void (^_Nonnull)(DJICameraDigitalFilter filter, NSError *_Nullable error))block;

/**
 *  Determines whether the device supports the quick view. Quick view is the
 *  period of time a photo is shown as a preview after it is taken and before
 *  the camera returns  to the live camera view.
 */
- (BOOL)isPhotoQuickViewSupported;

/**
 *  Sets the camera's quick view duration. The valid range is [0, 10] seconds. When duration is 0, it means that the quick view
 *  is disabled. The default value is 0 second.
 *  It is not supported by Phantom 3 Standard. Call `isPhotoQuickViewSupported` before using this method.
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
- (void)getPhotoQuickViewDurationWithCompletion:(void (^_Nonnull)(NSUInteger duration, NSError *_Nullable error))block;

/**
 *  Check if the current device supports digital zoom scale.
 *  It is only supported by Osmo with X3 camera and Phantom 4 camera.
 */
- (BOOL)isDigitalZoomScaleSupported;

/**
 *  Adjusts the digital zoom.
 *  It is only supported by Osmo.
 *
 *  @param scale    The valid range is from 1.0 to 2.0.
 *  @param block    The completion block with the returned execution result.
 */
- (void)setDigitalZoomScale:(float)scale withCompletion:(DJICompletionBlock)block;

/**
 * Gets current digital zoom.
 *
 * @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 * @see [- (void)setDigitalZoomScale:(float)scale withCompletion:(DJICompletionBlock)block;].
 */
- (void)getDigitalZoomScaleWithCompletion:(void (^_Nonnull)(float scale, NSError *_Nullable error))block;

/**
 *  Check if camera supports optical zoom.
 *  It is only supported by X5 and X5R camera with the Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ lens.
 *
 *  @return `YES` if camera supports optical zoom.
 */
-(BOOL)isOpticalZoomSupported;

/**
 *  Gets the specification of the zoom lens.
 *  It is only supported by X5 and X5R camera with lens Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ.
 *
 * @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 */
-(void)getOpticalZoomSpecWithCompletion:(void(^_Nonnull)(DJICameraOpticalZoomSpec spec, NSError *_Nullable error))block;

/**
 *  Sets focal length of the zoom lens.
 *  It is only supported by X5 and X5R camera with lens Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ.
 *
 *  @param focalLength  Focal length of zoom lens. Valid range is [`DJICameraOpticalZoomspec.minFocalLength`, `DJICameraOpticalZoomspec.maxFocalLength`] and must be a multiple of `DJICameraOpticalZoomspec.focalLengthStep`.
 *  @param block        The completion block with returned execution result.
 */
-(void)setOpticalZoomFocalLength:(NSUInteger)focalLength withCompletion:(DJICompletionBlock)block;

/**
 *  Gets zoom lens focal length in units of 0.1mm.
 *  It is only supported by X5 and X5R camera with lens Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ.
 *
 * @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 */
-(void)getOpticalZoomFocalLengthWithCompletion:(void (^_Nonnull)(NSUInteger focalLength, NSError *_Nullable error))block;

/**
 * Start changing the focal length of the lens in specified direction with specified speed. Focal length change (zooming) will halt when maximum or minimum focal lengths are reached, or `stopContinuousOpticalZoomWithCompletion` is called.
 *  It is only supported by X5 and X5R camera on Osmo with lens Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ.
 *
 *  @param direction    Direction to zoom. 
 *  @param speed        Zoom speed.
 *  @param block        The execution callback with the returned execution result.
 */
-(void)startContinuousOpticalZoomInDirection:(DJICameraOpticalZoomDirection)direction withSpeed:(DJICameraOpticalZoomSpeed)speed withCompletion:(DJICompletionBlock)block;


/**
 *  Called to stop focal length changing, when it currently is from calling `startContinuousOpticalZoomInDirection:withSpeed:withCompletion`.
 *  It is only supported by X5 and X5R camera on Osmo with lens Olympus M.Zuiko ED 14-42mm f/3.5-5.6 EZ.
 *
 *  @param block        The execution callback with the returned execution result.
 */
-(void)stopContinuousOpticalZoomWithCompletion:(DJICompletionBlock)block;

/*********************************************************************************/
#pragma mark Audio Settings
/*********************************************************************************/

/**
 *  Determines whether the current device supports audio recording.
 *  Currently audio recording is supported only by the Osmo camera.
 */
- (BOOL)isAudioRecordSupported;

/**
 *  Enables audio recording when capturing video.
 *  Supported only by Osmo camera.
 *
 *  @param enabled   Enable or disable audio recording.
 *  @param block     The execution callback with the returned execution result.
 *
 */
- (void)setAudioRecordEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Supported only by Osmo camera.
 *  Determines whether the audio record is enabled.
 *
 *  @param block    The execution callback with the returned value(s).
 */
- (void)getAudioRecordEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Sets the microphone recording gain.
 *  Only supported by Osmo.
 *  @param value    Recording gain with range [0,100].
 *  @param block    The completion block with the returned value(s).
 */
- (void)setAudioGain:(uint8_t)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the microphone recording gain.
 *  Only supported by Osmo.
 *
 *  @param block The completion block with the returned value(s).
 */
- (void)getAudioGainWithCompletion:(void (^_Nonnull)(uint8_t value, NSError *_Nullable error))block;

/**
 *  This method will turn off the camera's cooling fan whenever the camera is cool enough to do so. This allows better audio recording from the internal microphone in the camera.
 *  Supported Only by Osmo.
 *
 *  @param turnOffWhenPossible `true` to turn fan off whenever possible.
 *  @param block The execution block with the returned execution result.
 */
- (void)setTurnOffFanWhenPossible:(BOOL)turnOffWhenPossible withCompletion:(DJICompletionBlock)block;

/**
 *  Gets if the fan will turn off whenever it is cool enough to do so to enable better audio recordings from the camera's internal microphone.
 *
 *  @param block Remote execution result completion block.
 */
- (void)getTurnOffFanWhenPossibleWithCompletion:(void (^_Nonnull)(BOOL turnOffWhenPossible, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Advanced Camera Settings
/*********************************************************************************/

/**
 *  Determines whether the changeable lens is supported by the camera.
 *  Currently a changeable lens is supported only by the X5 and X5R cameras.
 */
- (BOOL)isChangeableLensSupported;

/**
 *  Gets details of the installed lens.
 *  Supported only by the X5 and X5R cameras.
 *  This is available only when `isChangeableLensSupported` returns `YES`.
 *
 *  @param callback The execution callback with the returned value(s).
 */
- (void)getLensInformationWithCompletion:(void (^_Nonnull)(NSString *_Nullable info, NSError *_Nullable error))block;

/**
 *  Determines whether the camera supports an adjustable aperture.
 *  Currently adjustable aperture is supported only by the X5 and X5R cameras.
 */
- (BOOL)isAdjustableApertureSupported;

/**
 *  Sets the aperture value.
 *  This feature is available only when `isAdjustableApertureSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  Precondition:
 *  The exposure mode must be in Manual or AperturePriority.
 *
 *  @param aperture The aperture to set. See [DJICameraLensFocusMode](../Enums/DJICameraLensFocusMode.html).
 *  @param block    The execution callback with the returned execution result.
 */
- (void)setAperture:(DJICameraAperture)aperture withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens aperture.`
 *  This feature is available only when `isAdjustableApertureSupported returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param block The execution callback with the returned value(s).
 */
- (void)getApertureWithCompletion:(void (^_Nonnull)(DJICameraAperture aperture, NSError *_Nullable error))block;

/**
 *  Determines whether the camera supports an adjustable focal point.
 *  Currently, the adjustable focal point is supported only by the X5 and X5R cameras.
 */
- (BOOL)isAdjustableFocalPointSupported;

/**
 *  Sets the lens focus mode. See [DJICameraLensFocusMode](../Enums/DJICameraLensFocusMode.html).
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param focusMode    Focus mode to set. See [DJICameraLensFocusMode](../Enums/DJICameraLensFocusMode.html) for more detail.
 *  @param block        The execution callback with the returned execution result.
 */
- (void)setLensFocusMode:(DJICameraLensFocusMode)focusMode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens focus mode. See [DJICameraLensFocusMode](../Enums/DJICameraLensFocusMode.html).
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 * @param block The execution callback with the returned value(s).
 */
- (void)getLensFocusModeWithCompletion:(void (^_Nonnull)(DJICameraLensFocusMode focusMode, NSError *_Nullable error))block;

/**
 *  Sets the lens focus target point.
 *  When the focus mode is auto, the target point is the focal point.
 *  When the focus mode is manual, the target point is the zoom out area if the focus assistant is enabled for
 *  the manual mode.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param focusTarget  The focus target to set. The range for x and y is from 0.0 to 1.0. The point [0.0, 0.0]
 *                      represents the top-left angle of the screen.
 *  @param block        The execution callback with the returned execution result.
 *
 */
- (void)setLensFocusTarget:(CGPoint)focusTarget withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens focus target point.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param callback The execution callback with the returned value(s).
 */
- (void)getLensFocusTargetWithCompletion:(void (^_Nonnull)(CGPoint focusTarget, NSError *_Nullable error))block;

/**
 *  Sets whether the lens focus assistant is enabled.
 *  If the focus assistant is enabled, a specific area of the screen will zoom out during focusing.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param enabledMF    Sets whether the lens focus assistant under MF mode is enabled.
 *  @param enabledAF    Sets whether the lens focus assistant under AF mode is enabled.
 *  @param block        The execution callback with the returned execution result.
 */
- (void)setLensFocusAssistantEnabledForMF:(BOOL)MFenabled andAF:(BOOL)AFenabled withCompletion:(DJICompletionBlock)block;

/**
 *  Determines whether the lens focus assistant is enabled.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param block The execution callback with the returned value(s).
 *  The first result stands for MF, the second result stands for AF.
 */
- (void)getLensFocusAssistantEnabledForMFAndAFWithCompletion:(void (^_Nonnull)(BOOL MFenabled, BOOL AFenabled, NSError *_Nullable error))block;

/**
 *  Gets the lens focusing ring value's max value.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param callback The execution callback with the returned value(s).
 */
- (void)getLensFocusRingValueUpperBoundWithCompletion:(void (^_Nonnull)(NSUInteger upperBound, NSError *_Nullable error))block;

/**
 *  Set the focal distance by simulating the focus ring adjustment. Value can have a range of [0, `getLensFocusRingValueUpperBoundWithCompletion`], which represents infinity and the closest possible focal distance.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  For some lenses, the minimum focus ring value is larger than 0. For example the minimum of DJI MFT 15mm f/1.7 ASPH is 270.
 *  To retrieve the minimum value, perform the following steps:
 *
 *  - Call `setLensFocusMode` with `DJICameraLensFocusModeAuto`.
 *  - Call `setLensFocusTarget` with the furthest target (>30m).
 *  - Call `getLensFocusRingValue` to get the current focus ring value. This is the minimum value. The maximum value can be retrieved using `getLensFocusRingValueUpperBoundWithCompletion`.
 *
 *   @param value   Value to which to the adjust focus ring.
 *                  The minimum value is 0, the maximum value depends on the installed lens. Call the
 *                  `getLensFocusRingValueUpperBoundWithCompletion` method to ensure the input argument is valid.
 *  @param block    The execution callback with the returned execution result.
 */
- (void)setLensFocusRingValue:(NSUInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lens focus ring value.
 *  It is available only when `isAdjustableFocalPointSupported` returns `YES`.
 *  Supported only by the X5 and X5R cameras.
 *
 *  @param callback The execution callback with the returned value(s).
 */
- (void)getLensFocusRingValueWithCompletion:(void (^_Nonnull)(NSUInteger distance, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Save/load camera settings
/*********************************************************************************/

/**
 *  Load the camera's factory settings. <br>
 *  Also supported by thermal imaging camera.
 *
 *  Post condition:
 *  The camera will reboot itself.
 *
 *  @param callback The execution callback with the returned execution result.
 */
- (void)loadFactorySettings:(DJICompletionBlock)block;

/**
 *  Saves the current camera settings permanently to the specified user. See [DJICameraCustomSettings](../Enums/DJICameraCustomSettings.html) to view all possible camera users.
 *
 *  @param settings Camera user for which to store camera settings.
 *  @param result   Remote execution result error block.
 */
- (void)saveSettingsTo:(DJICameraCustomSettings)settings withCompletion:(DJICompletionBlock)block;

/**
 *  Load camera settings from the specified user.
 *
 *  @param settings Camera user from which to load camera settings.
 *  @param result   Remote execution result error block.
 */
- (void)loadSettingsFrom:(DJICameraCustomSettings)settings withCompletion:(DJICompletionBlock)block;

@end

/*********************************************************************************/
#pragma mark - DJICamera (Media)
/*********************************************************************************/

@interface DJICamera (Media)
/**
 *  Check if the current device supports Media Download Mode.
 */
- (BOOL)isMediaDownloadModeSupported;

@end

/*********************************************************************************/
#pragma mark - DJICamera (CameraPlayback)
/*********************************************************************************/

@interface DJICamera (CameraPlayback)

/**
 *  Check if the current device supports Playback Mode.
 */
- (BOOL)isPlaybackSupported;

@end

/*********************************************************************************/
#pragma mark - DJISDCardOperations
/*********************************************************************************/

/**
 *  You can store high quality photos and videos on an SD card.
 */
@interface DJICamera (SDCardOperations)

/**
 *  Formats the SD card by deleting all the data on the SD card. This
 *  does not change any settings the user may have set on the SD card.
 */
- (void)formatSDCardWithCompletion:(DJICompletionBlock)block;

/**
 *  Gets the current state of the SD card. For instance, accessing the sdInfo parameter of the block will tell you whether or not the SD card is inserted into the camera or how much memory is remaining. For more information on all possible current states of the SD card, see DJICameraSDCardState.
 *
 *  @param block Remote execution result callback block.
 *
 *  @deprecated Call [DJICameraDelegate camera:didUpdateSDCardState:] instead.
 */
- (void)getSDCardInfoWithCompletion:(void (^_Nonnull)(DJICameraSDCardState *_Nullable sdInfo, NSError *_Nullable error))block DJI_API_DEPRECATED("Use camera:didUpdateSDCardState: in DJICameraDelegate instead. ");

@end

/*********************************************************************************/
#pragma mark - DJISSDOperations
/*********************************************************************************/

/**
 *   Both X5 and X5R cameras are DSLR quality cameras that can save JPEG, lossless raw images, MP4 videos, and raw videos requiring very high amounts of storage in the range of 500 Gb or more. A Solid State Drive (SSD) provides such storage. Note that JPEG is a compressed format, and raw images store much more information and allow for a full range of postprocessing features.
 */
@interface DJICamera (SSDOperations)
/**
 *  Determines whether the SSD is supported by the camera.
 *  Currently, the SSD is supported only by X5R camera.
 */
- (BOOL)isSSDSupported;

/**
 *  Formats the SSD by deleting all the data on the SSD. This
 *  does not change any settings the user may have set on the SSD.
 */
- (void)formatSSDWithCompletion:(DJICompletionBlock)block;

/**
 *  Set Raw Video Resolution and Frame Rate of the SSD.
 *
 *  Note, only raw video is saved to the SSD. Compressed video, compressed pictures
 *  and raw pictures are all saved to the SD Card. During video capture, Raw video and
 *  compressed video are saved simultaneously to the SSD and SD Card respectively.
 *
 *  @warning The supported resolutions and frame rates for SSD Raw Videos are shown below:
 *    <br/><br/>
 *    <b>NTSC:</b><br/> Resolution_4096x2160, FrameRate_24fps<br/>
 *          Resolution_3840x2160, FrameRate_24fps<br/>
 *          Resolution_3840x2160, FrameRate_30fps<br/>
 *          Resolution_2704X1520, FrameRate_24fps<br/>
 *          Resolution_2704X1520, FrameRate_30fps<br/>
 *          Resolution_1920x1080, FrameRate_60fps<br/>
 *          Resolution_1920x1080, FrameRate_48fps<br/>
 *          Resolution_1920x1080, FrameRate_30fps<br/>
 *          Resolution_1920x1080, FrameRate_24fps<br/><br/>
 *    <br/><br/>
 *    <b>PAL:</b><br/> Resolution_4096x2160, FrameRate_25fps<br/>
 *          Resolution_4096x2160, FrameRate_24fps<br/>
 *          Resolution_3840x2160, FrameRate_25fps<br/>
 *          Resolution_3840x2160, FrameRate_24fps<br/>
 *          Resolution_2704X1520, FrameRate_25fps<br/>
 *          Resolution_2704X1520, FrameRate_24fps<br/>
 *          Resolution_1920x1080, FrameRate_50fps<br/>
 *          Resolution_1920x1080, FrameRate_48fps<br/>
 *          Resolution_1920x1080, FrameRate_25fps<br/>
 *          Resolution_1920x1080, FrameRate_24fps<br/><br/>
 *
 *  @param resolution Resolution to be set for the video.
 *  @param frameRate Frame rate to be set for the video.
 *  @param block Remote execution result error block.
 */
- (void)setSSDRawVideoResolution:(DJICameraVideoResolution)resolution andFrameRate:(DJICameraVideoFrameRate)frameRate withCompletion:(DJICompletionBlock)block;

/**
 *  Get Raw Video Format and Frame Rate of the SSD.
 *
 *  @param block Get raw video resolution and frame rate result callback block.
 */
- (void)getSSDRawVideoResolutionAndFrameRateWithCompletion:(void (^_Nonnull)(DJICameraVideoResolution resolution, DJICameraVideoFrameRate frameRate, NSError *_Nullable error))block;

@end

/*********************************************************************************/
#pragma mark - Thermal Imaging Camera
/*********************************************************************************/

@interface DJICamera (ThermalCamera)
/**
 *  `YES` if the current connected device is a thermal imaging camera.
 *
 *  @return BOOL `Yes` if current connected device is thermal imaging camera.
 */
- (BOOL)isThermalImagingCamera;

/**
 *  Sets the Region of Interest (ROI). Used to manage color range distribution across the screen to maximize contrast for regions of highest interest.
 *  Supported only by thermal imaging cameras.
 *
 *  @param roi An enum type of the Region of Interest to be used(see [DJICameraThermalROI](../Enums/DJICameraThermalROI.html)).
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalROI:(DJICameraThermalROI)roi withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the Region of Interest.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalROI:(DJICameraThermalROI)roi withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalROIWithCompletion:(void (^_Nonnull)(DJICameraThermalROI roi, NSError *_Nullable error))block;

/**
 *  Sets the Palette. Each palette is a unique look-up table that maps 8-bit temperature values to different colors. Different palettes can be used to help the user better visualize temperature contrast or specific temperature bands.
 *  Supported only by thermal imaging cameras.
 *
 *  @param palette An enum type of the CameraThermalPalette to be used(see [DJICameraThermalPalette](../Enums/DJICameraThermalPalette.html)).
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalPalette:(DJICameraThermalPalette)palette withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the Palette.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalPalette:(DJICameraThermalPalette)palette withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalPaletteWithCompletion:(void (^_Nonnull)(DJICameraThermalPalette palette, NSError *_Nullable error))block;

/**
 *  Sets the scene to instantly enhance your image.
 *  In all modes except Manual and User modes, the DDE, ACE, SSO, brightness and contrast are set automatically to obtain the best result.
 *  In User modes, the DDE, brightness and contrast are set automatically to obtain the best results. Any settings that are made in these modes are retained if the scene is changed.
 *  In Manual mode, DDE, ACE, SSO, brightness and contrast are set manually.
 *  Supported only by thermal imaging cameras.
 *
 * @param scene An enum type for the CameraThermalScene to be used (see [DJICameraThermalScene](../Enums/DJICameraThermalScene.html)).
 * @param block Completion block that receives the getter execution result.
 */
- (void)setThermalScene:(DJICameraThermalScene)scene withCompletion:(DJICompletionBlock)block;

/**
 *  Gets current scene.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalScene:(DJICameraThermalScene)scene withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalSceneWithCompletion:(void (^_Nonnull)(DJICameraThermalScene scene, NSError *_Nullable error))block;

/**
 *  Sets the Digital Data Enhancement index (for DDE dynamic mode). DDE can be used to enhance image details (sharpen, higher index) and/or suppress fixed pattern noise (soften, lower index).
 *  It can be set manually only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value Integer in range [-20, 100].
 *               Values less than 0 soften the image and filter fixed pattern noise.
 *               Values greater than 0 sharpen the details in the image.
 *               Value of 0 results in no enhancement
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalDDE:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the value of Digital Data Enhancement. The value is available only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 * @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 * @see [- (void)setThermalDDE:(NSInteger)value withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalDDEWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;

/**
 *  Set the value of Active Contrast Enhancement. Active contrast enhancement allows for a contrast trade-off between hotter and colder scenes when using 8-bit pixel data.
 *  It can be set manually only when the Scene mode is User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value Integer in range [-8, 8].
 *               value > 0: more contrast in hotter scene content and less contrast in colder scene content (sky, ocean etc.).
 *               value < 0: more contrast in colder scene content and less contrast in hotter scene content.
 *               value = 0: neutral
 *               value = 3: recommended for generic use
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalACE:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the value of Active Contrast Enhancement.
 *  The value is available only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 * @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 * @see [- (void)setThermalACE:(NSInteger)value withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalACEWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;


/**
 *  Sets the value of Smart Scene Optimization.
 *  When using non-linear histogram equalization to map the 14-bit sensor pixel values to 8-bit pixel values, it can become difficult to determine the difference in temperature of two objects from their different shades of gray. SSO allows a percentage of the 14-bit histogram to be mapped linearly to the 8-bit histogram, which will compromise local contrast, but allow for more accurate visual radiometric measurements. This is particularly useful for bi-modal scenes.
 *  It can be set manually only when the Scene mode is User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value Percentage of histogram to map linearly [0, 100].
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalSSO:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the value of Smart Scene Optimization.
 *  The value is available only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalSSO:(NSInteger)value withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalSSOWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;

/**
 *  Sets the brightness of the image.
 *  It can be set manually only when the Scene mode is Manual.
 *  Supported only by thermal imaging cameras.
 *
 *  @param brightness The integer value falls in [0, 16383].
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalBrightness:(NSUInteger)brightness withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the value of brightness.
 *  The value is available only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalBrightness:(NSUInteger)brightness withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalBrightnessWithCompletion:(void (^_Nonnull)(NSUInteger brightness, NSError *_Nullable error))block;

/**
 *  Sets the value of contrast, with larger values having higher contrast.
 *  It can be set manually only when the Scene mode is Manual.
 *  Supported only by thermal imaging cameras.
 *
 *  @param contrast Contrast value as an integer with range [0, 255].
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalContrast:(NSUInteger)contrast withCompletion:(DJICompletionBlock)block;

/**
 *  Gets contrast value.
 *  The value is available only when the Scene mode is Manual, User1, User2 or User3.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalContrast:(NSUInteger)contrast withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalContrastWithCompletion:(void (^_Nonnull)(NSUInteger Contrast, NSError *_Nullable error))block;

/**
 *  Enable or disable Isotherms. Isotherms can be used to highlight specific
 *  temperature ranges:
 *  When disabled, all 256 values (8-bits) are dedicated to the temperature
 *  histogram of the scene.
 *  When enabled, only 128 values (0-127) are mapped linearly to temperature.
 *  Then three bands 128-175, 176-223 and 224-255 can be mapped to the user
 *  defined temperatures to highlight them to the user. Using some of the false
 *  color palettes (like RainbowIso) results in a thermal image that is grey
 *  scale except for three specific bands highlighted by either reds, blues or
 *  greens.
 *  Supported only by thermal imaging cameras.
 *
 * @param enabled YES if isotherms are enabled.
 * @param block Completion block that receives the getter execution result.
 */
- (void)setThermalIsothermEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block;

/**
 *  Determines whether Isotherms are enabled. `YES` if Isotherms are enabled.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 */
- (void)getThermalIsothermEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled, NSError *_Nullable error))block;

/**
 *  Sets the unit of the Isotherm ranges to either Celsius or percent. Different units results in different value ranges for Isotherms.
 *  Supported only by thermal imaging cameras.
 *
 *  @param unit An enum type of the CameraThermalIsothermUnit to be used(see [DJICameraThermalIsothermUnit](../Enums/DJICameraThermalIsothermUnit.html)).
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalIsothermUnit:(DJICameraThermalIsothermUnit)unit withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the units for Isotherm ranges.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error
 *               occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalIsothermUnit:(DJICameraThermalIsothermUnit)unit withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalIsothermUnitWithCompletion:(void (^_Nonnull)(DJICameraThermalIsothermUnit unit, NSError *_Nullable error))block;

/**
 *  Sets the upper threshold value for Isotherm. All temperature values above this will use colors 224-255 from the palette.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value If the unit is percentage, the allowed range is [0,100].
 *               If the unit is Celsius, the allowed range is [-40, 550].
 *               The value can only be equal or larger than middle Isotherm threshold.
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalIsothermUpperValue:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the upper threshold value for Isotherm.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalIsothermUpperValue:(NSInteger)value withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalIsothermUpperValueWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;

/**
 *  Sets the middle threshold value for Isotherm. Temperature values between the middle and upper Isotherm threshold will be displayed with colors 176-223 from the palette.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value If the unit is percentage, the value falls in [0,100].
 *               If the unit is Celsius, the value range is [-40, 550].
 *               The value can only be equal or larger than lower threshold and equal or smaller than upper threshold.
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalIsothermMiddleValue:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the middle threshold value for Isotherm.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalIsothermMiddleValue:(NSInteger)value withCompletion:(DJICompletionBlock)block] method.
 */
- (void)getThermalIsothermMiddleValueWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;

/**
 *  Sets the lower threshold value for Isotherm. Temperature values between the lower and middle Isotherm threshold will be displayed with colors 128-175 from the palette.
 *  Supported only by thermal imaging cameras.
 *
 *  @param value If the unit is percentage, the value falls in [0,100].
 *               If the unit is Celsius, the value range is [-40, 550].
 *               The value can only be equal or smaller than upper threshold.
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalIsothermLowerValue:(NSInteger)value withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the lower threshold value for Isotherm.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalIsothermLowerValue:(NSInteger)value withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalIsothermLowerValueWithCompletion:(void (^_Nonnull)(NSInteger value, NSError *_Nullable error))block;

/**
 *  Sets the gain mode. Low gain mode can be used for scenes with temperatures ranging from -40 to 550 degrees Celsius. For higher contrast, the high gain mode can be used by for temperatures between -25 to 135 degrees Celsius for the 640x512 camera and -25 to 100 degrees Celsius for 324 x 256 camera.
 *  Supported only by thermal imaging cameras.
 *
 *  @param mode An enum type of the CameraThermalGainMode to be used(see [DJICameraThermalGainMode](../Enums/DJICameraThermalGainMode.html)).
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalGainMode:(DJICameraThermalGainMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the gain mode.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalGainMode:(DJICameraThermalGainMode)mode withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalGainModeWithCompletion:(void (^_Nonnull)(DJICameraThermalGainMode mode, NSError *_Nullable error))block;

/**
 *  Enable or disable the temperature measurement data delegate method
 *  `[camera:didUpdateTemperatureData:]` in `DJICameraDelegate`. For the XT, the
 *  measurement data is at the center of the image.
 *  Supported only by thermal imaging cameras.
 *
 *  @param enabled `YES` to start `[camera:didUpdateTemperatureData:]`, NO to stop.
 *  @param block Completion block that receives the getter execution result.
 *  @deprecated Call `setThermalMeasurementMode:withCompletion:` instead.
 */
- (void)setThermalTemperatureDataEnabled:(BOOL)enabled
                          withCompletion:(DJICompletionBlock)block
DJI_API_DEPRECATED("Use setThermalMeasurementMode:withCompletion:. ");

/**
 *  Gets if `[camera:didUpdateTemperatureData:]` in `DJICameraDelegate` is enabled or not.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error
 *               occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalTemperatureDataEnabled:(BOOL)enabled withCompletion:(DJICompletionBlock)block].
 *  @deprecated Call `getThermalMeasurementModeWithCompletion:` instead.
 */
- (void)getThermalTemperatureDataEnabledWithCompletion:(void (^_Nonnull)(BOOL enabled,
                                                                         NSError *_Nullable error))block
DJI_API_DEPRECATED("Use getThermalMeasurementModeWithCompletion:. ");

/**
 *  Sets the mode for thermal measurement.
 *  Use delegate method `camera:didUpdateTemperatureData:` or 
 *  `camera:didUpdateAreaTemperatureAggregations` in `DJICameraDelegate` to
 *  receive the measurement result.
 *  Supported only by thermal imaging cameras.
 *
 *  @param mode  The desired measurement mode.
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalMeasurementMode:(DJICameraThermalMeasurementMode)mode
                   withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the mode for thermal measurement.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error
 *               occurs, the error is returned and the result is undefined.
 */
- (void)getThermalMeasurementModeWithCompletion:(void (^_Nonnull)(DJICameraThermalMeasurementMode mode,
                                                                  NSError *_Nullable error))block;

/**
 *  Adjusts the digital zoom.
 *  Supported only by thermal imaging cameras.
 *
 *  @param scale For resolution 640 x 512, x1,x2,x4,x8 can be set. For resolution 336 × 256, only x1,x2,x4 can be set(see [DJICameraThermalDigitalZoomScale](../Enums/DJICameraThermalDigitalZoomScale.html))
 *  @param block Completion block that receives the getter execution result.
 */
- (void)setThermalDigitalZoomScale:(DJICameraThermalDigitalZoomScale)scale withCompletion:(DJICompletionBlock)block;

/**
 *  Gets current digital zoom.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 *  @see [- (void)setThermalDigitalZoomScale:(DJICameraThermalDigitalZoomScale)scale withCompletion:(DJICompletionBlock)block].
 */
- (void)getThermalDigitalZoomScaleWithCompletion:(void (^_Nonnull)(DJICameraThermalDigitalZoomScale scale, NSError *_Nullable error))block;

/**
 *  Gets the thermal imaging camera profile. The profile includes information about resolution, frame rate and focal length.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter result. When an error occurs, the error is returned and the result is undefined.
 */
- (void)getThermalProfileWithCompletion:(void (^_Nonnull)(DJICameraThermalProfile profile, NSError *_Nullable error))block;

/**
 *  Gets the spot metering target point if one is set, if not then returns CGPointZero. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param block Completion block that receives the getter execution result.
 */
- (void)getThermalSpotMeteringTargetPointWithCompletion:(void (^_Nonnull)(CGPoint targetPoint, NSError *_Nullable error))block;

/**
 *  Sets the spot metering target point which then changes the camera:didUpdateTemperatureData: delegate call to return 
 *  the temperature at a specific coordinate in the scene.
 *
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param targetPoint The desired target point
 *  @param block       Completion block that receives the setter execution result.
 */
- (void)setThermalSpotMeteringTargetPoint:(CGPoint)targetPoint withCompletion:(DJICompletionBlock)block;

/**
 *  Get a rect representing the currently set metering area for the thermal scene. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param block Completion block that receives the getter execution result.
 */
- (void)getThermalMeteringAreaWithCompletion:(void (^_Nonnull)(CGRect area, NSError *_Nullable error))block;

/**
 *  Set the metering area for a rectangle inside the thermal image scene, which
 *  allows the camera to transmit aggregate temperature computations via the
 *  `camera:didUpdateAreaTemperatureAggregations:` delegate method.
 *  See `DJICameraThermalAreaTemperatureAggregations` for the statistical values
 *  that are available.
 *  This method requires a relative rect that is proportional to the rect of the
 *  thermal scene, the x, y, width, and height values must all be between 0 and 1.0.
 *
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param The desired thermal metering area.
 *  @param block Completion block that receives the setter execution result.
 */
- (void)setThermalMeteringArea:(CGRect)area withCompletion:(DJICompletionBlock)block;

/**
 *  Get the currently set flat-field correction (FFC) mode. 
 *
 *  Supported only by thermal imaging cameras with installed firmware version of 1.15.1.60 or higher.
 *
 *  @param block Completion block that receives the getter execution result.
 */
- (void)getThermalFFCModeWithCompletion:(void (^_Nonnull)(DJICameraThermalFFCMode mode, NSError *_Nullable error))block;

/**
 *  Set the flat-field correction (FFC) mode. 
 *
 *  Supported only by thermal imaging cameras.
 *
 *  @param mode  The desired FFC mode.
 *  @param block Completion block that receives the setter execution result.
 */
- (void)setThermalFFCMode:(DJICameraThermalFFCMode)mode withCompletion:(DJICompletionBlock)block;

/**
 *  Trigger flat-field correction. 
 *
 *  Supported only by thermal imaging cameras.
 *
 *  @param Completion block that receives the execution result of the trigger action.
 */
- (void)triggerThermalFFCModeWithCompletion:(DJICompletionBlock)block;

/**
 *  Get the currently set custom user profile. This profile represents user-set
 *  external scene parameters for the thermal scene.
 *  Supported only by thermal imaging cameras.
 *
 *  @param block Completion block that receives the getter execution result.
 */
- (void)getThermalCustomExternalSceneSettingsProfileWithCompletion:(void (^_Nonnull)(DJICameraThermalCustomExternalSceneSettings profile, NSError *_Nullable error))block;

/**
 *  Set the custom user profile. This profile represents user-set external scene
 *  parameters for the thermal scene.
 *  Supported only by thermal imaging cameras.
 *
 *  @param profile The desired user profile setting.
 *  @param block   Completion block that receives the setter execution result.
 */
- (void)setThermalCustomExternalSceneSettingsProfile:(DJICameraThermalCustomExternalSceneSettings)profile withCompletion:(DJICompletionBlock)block;

/**
 *  Set the temperature of the atmosphere between the scene and the camera. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param temperature  The assumed temperature of the atmosphere between the
 *                      camera and the scene, can be between -50 and 327.67
 *                      degrees Celsius.
 *  @param block        Completion block that receives the setter execution result.
 */
- (void)setThermalAtmosphericTemperature:(float)temperature withCompletion:(DJICompletionBlock)block;

/**
 *  Set the transmission coefficient of the atmosphere between the scene and the
 *  camera.
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param coefficient The desired atmospheric temperature, can be between 50 and 100.
 *  @param block       Completion block that receives the setter execution result.
 */
- (void)setThermalAtmosphericTransmissionCoefficient:(float)coefficient withCompletion:(DJICompletionBlock)block;

/**
 *  Set the assumed temperature reflected by the background of the scene, can be
 *  between -50 and 327.67 degrees Celsius.
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param temperature  The desired background reflected temperature.
 *  @param block        Completion block that receives the setter execution result.
 */
- (void)setThermalBackgroundTemperature:(float)temperature withCompletion:(DJICompletionBlock)block;

/**
 *  Set the emissivity of the thermal scene, can be between 50 and 100. 
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param emissivity The desired scene emissivity.
 *  @param block      Completion block that receives the setter execution result.
 */
- (void)setThermalSceneEmissivity:(float)emissivity withCompletion:(DJICompletionBlock)block;

/**
 *  Set assumed window reflection coefficient, can be between 0 and X where X is
 *  the window transmission coefficient parameter.
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param reflection The desired window reflection coefficient.
 *  @param block      Completion block that receives the setter execution result.
 */
- (void)setThermalWindowReflection:(float)reflection withCompletion:(DJICompletionBlock)block;

/**
 *  Set the temperature reflected in the window, can be between -50 and 327.67
 *  degrees Celsius.
 *
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param temperature  The desired window reflected temperature.
 *  @param block        Completion block that receives the setter execution result.
 */
- (void)setThermalWindowReflectedTemperature:(float)temperature withCompletion:(DJICompletionBlock)block;

/**
 *  Set the window temperature, can be between -50 and 327.67 degrees Celsius. 
 *
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param temperature  The desired window temperature.
 *  @param block        Completion block that receives the setter execution result.
 */
- (void)setThermalWindowTemperature:(float)temperature withCompletion:(DJICompletionBlock)block;

/**
 *  Set the window transmission coefficient, can be between 50 and 100-X where X
 *  is the window reflection.
 *  Supported only by Zenmuse XT containing Advanced Radiometry capabilities.
 *
 *  @param coefficient The desired window transmission coefficient.
 *  @param block       Completion block that receives the setter execution result.
 */
- (void)setThermalWindowTransmissionCoefficient:(float)coefficient withCompletion:(DJICompletionBlock)block;

@end

NS_ASSUME_NONNULL_END
