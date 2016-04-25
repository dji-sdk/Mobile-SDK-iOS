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
     *  180 Degree Panorama mode. Also known as selfie mode.
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
 *  During a Panorama Mission, the user can rotate the camera 360 or 180 degrees to take several photos, and then download the photos to render a panorama.
 *  In full circle mode, 8 photos are taken. In half circle mode, 5 photos are taken.
 *  Commands cannot be sent to the camera until the mission is finished. The Panorama Mission does not support the image stitching feature, so the images must be stitched manually. All the images will be stored on the SD card.
 *
 *  Panorama Mission is only supported by Osmo with X3 camera.
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
 *  Retrieves the `DJIMedia` object for the recently finished panorama mission. Call the `fetchSubMediaFileListWithCompletion:` method on the retrieved `DJIMedia` to
 *  retrieve the panorama photos.
 */
- (void)getPanoramaMediaFileWithCompletion:(void (^)(DJIMedia *_Nullable panoMedia, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END