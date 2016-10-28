//
//  DJIRecordVideoStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a step related to video-recording for a custom mission. By creating an object of this class and adding it into a custom mission, the user can record video during the custom mission execution.
 */
@interface DJIRecordVideoStep : DJIMissionStep

/**
 *  Initialized instance with duration.
 *
 *  @param duration Duration in seconds for recording video.
 *
 *  @return Instance of `DJIRecordVideoStep`
 */
- (instancetype _Nullable)initWithDuration:(double)duration;

/**
 *  Initialized instance for start video recording only.
 *
 *  @return Instance of `DJIRecordVideoStep`
 */
- (instancetype _Nullable)initWithStartRecordVideo;

/**
 *  Initialized instance for stop video recording only.
 *
 *  @return Instance of `DJIRecordVideoStep`
 */
- (instancetype _Nullable)initWithStopRecordVideo;

@end

NS_ASSUME_NONNULL_END
