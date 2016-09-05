//
//  DJICameraParameters.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJICameraSettingsDef.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Range Key of the change dictionary.
/**
 *  CameraVideoResolutionAndFrameRateRange key.
 */
extern NSString *const DJISupportedCameraVideoResolutionAndFrameRateRange;

/**
 *  CameraModeRange key
 */
extern NSString *const DJISupportedCameraModeRange;

/**
 *  CameraExposureModeRange key
 */
extern NSString *const DJISupportedCameraExposureModeRange;

/**
 *  CameraISORange key
 */
extern NSString *const DJISupportedCameraISORange;

/**
 *  CameraShutterSpeedRange key
 */
extern NSString *const DJISupportedCameraShutterSpeedRange;

/**
 *  CameraExposureCompensationRange key
 */
extern NSString *const DJISupportedCameraExposureCompensationRange;

/**
 *  DJISupportedCameraApertureRange key
 */
extern NSString *const DJISupportedCameraApertureRange;


@class DJICameraParameters;

/**
 *  This protocol provides a method that is notified when the camera parameters' range changes.
 */
@protocol DJICameraParametersListener <NSObject>

@optional

/**
 *  When a parameter range is changed, the listener will receive this callback.
 *
 *  @param parameters The parameters.
 *  @param change     The new range and key.
 */
- (void)cameraParameters:(nonnull DJICameraParameters *)parameters change:(nonnull NSDictionary<id, NSString *> *)change;

@end

/**
 *  Some of the camera's parameters have dynamic ranges. The `DJICameraParameters` interface allows you to query the
 *  valid range for a parameter. Type-casting is required to get the corresponding enumerator value for each
 *  range element.
 */

@interface DJICameraParameters : NSObject

/**
 *  Returns an instance of `DJICameraParameters` Object
 */
+ (nonnull instancetype)sharedInstance;

/**
 *  Returns the current valid range for video resolution ([DJICameraVideoResolution](../Enums/DJICameraVideoResolution.html)) and frame rate
 *  (`DJICameraVideoFrameRate`). Returns nil if the current camera does not support any video resolution or frame rate
 *  setting, or if the camera is disconnected.
 *
 *  @return Array of pairs, each consisting of a valid `DJICameraVideoResolution` value and `DJICameraVideoFrameRate`
 *          value.
 */
- (nonnull NSArray<NSArray<NSNumber *> *> *)supportedCameraVideoResolutionAndFrameRateRange;

/**
 *  Returns the current valid range for camera mode ([DJICameraMode](../Enums/DJICameraMode.html)). Returns nil if current camera has no supported
 *  camera mode or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represents one current supported camera mode.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraModeRange;

/**
 *  Returns the current valid range for camera's exposure mode ([DJICameraExposureMode](../Enums/DJICameraExposureMode.html)). Returns nil if current
 *  camera does not support any exposure mode or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represent one current supported exposure mode.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraExposureModeRange;

/**
 *  Returns the current valid range for camera's ISO (see [DJICameraISO](../Enums/DJICameraISO.html)). Returns nil if current camera does not support
 *  any ISO value or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represent one current supported ISO value.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraISORange;

/**
 *  Returns the current valid range for camera's shutter speed (see [DJICameraShutterSpeed](../Enums/DJICameraShutterSpeed.html)). Returns nil if current
 *  camera does not support any shutter speed value or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represent one current supported shutter speed value.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraShutterSpeedRange;

/**
 *  Returns the current valid range for camera's exposure compensation (see [DJICameraExposureCompensation](../Enums/DJICameraExposureCompensation.html)). Returns
 *  nil if current camera does not support any exposure compensation value or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represent one current supported exposure compensation value.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraExposureCompensationRange;

/**
 *  Returns the current valid range for camera's aperture (see [DJICameraAperture](../Enums/DJICameraAperture.html)). Returns nil if current camera does
 *  not support any aperture value or the camera is disconnected.
 *
 *  @return Array of NSNumber. Each element represent one current supported aperture value.
 */
- (nonnull NSArray<NSNumber *> *)supportedCameraApertureRange;

@end

/**
 *  A category of DJICameraParameters. It provides methods to add or remove listeners for valid range change.
 */
@interface DJICameraParameters (Listener)

/**
 *  Add listener to listen for the camera range change.
 *
 *  @param listener listener
 */
- (void)addListener:(nonnull id<DJICameraParametersListener>)listener;

/**
 *  Remove listener which is listening to the camera range change.
 *
 *  @param listener listener
 */
- (void)removeListener:(nonnull id<DJICameraParametersListener>)listener;

/**
 *  Remove all listeners.
 */
- (void)removeAllListeners;

@end

NS_ASSUME_NONNULL_END