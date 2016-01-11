//
//  DJIPanoramaMission.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import "DJIMission.h"

NS_ASSUME_NONNULL_BEGIN

@class DJIMedia;

/**
 *  Defines options for different types of modes for panorama mission.
 */
typedef NS_ENUM (NSUInteger, DJIPanoramaMode) {
    /**
     *  360 Degree Panorama mode
     */
    DJIPanoramaModeFullCircle = 0,
    /**
     *  180 Degree Panorama mode. Also known as selfie mode in OSMO.
     */
    DJIPanoramaModeHalfCircle,
    /**
     *  Unknown mode.
     */
    DJIPanoramaModeUnknown = 0xFF
};

/**
 *  This class provides the real-time status of an executing panorama mission.
 */
@interface DJIPanoramaMissionStatus : DJIMissionProgressStatus

/**
 *  The total number of photos will be shot during the mission.
 *  In the full circle mode, the number should be 8.
 *  In the half circle mode, the number should be 5.
 */
@property(nonatomic, readonly) NSUInteger totalNumber;

/**
 *  The number of photos that have been shot.
 */
@property(nonatomic, readonly) NSUInteger currentShotNumber;

/**
 *  The number of photos that have been saved to SD card.
 */
@property(nonatomic, readonly) NSUInteger currentSavedNumber;

@end

/**
 *  User can use this mission to rotate camera 360 or 180 degrees to takes several photos. Then download the photos to render a panorama. Please note that
 *  photo stitching is not provided in the SDK. In full circle mode, 8 photos are taken. In half circle mode, 5 photos are taken.
 */
@interface DJIPanoramaMission : DJIMission

/**
 *  Returns the current panorama mode of this mission.
 */
@property (nonatomic, readonly) DJIPanoramaMode panoramaMode;

/**
 *  Initializer for the Panorama mission object with panorama mode.
 */
- (id)initWithPanoramaMode:(DJIPanoramaMode)mode;

/**
 *  Retrieves the DJIMedia object for the recently finished panorama mission. Use `fetchSubMediaFileListWithCompletion:` method on the retrieved DJIMedia to
 *  retrieve the panorama photos.
 */
- (void)getPanoramaMediaFileWithCompletion:(void (^)(DJIMedia *_Nullable panoMedia, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END