//
//  DJIShootPhotoStep.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <DJISDK/DJIMissionStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents a step related to photo-shooting for a custom mission. By creating an object of this class and adding it to a custom mission, the user can shoot photos during the custom mission execution.
 */
@interface DJIShootPhotoStep : DJIMissionStep

/**
 *  Initialized step for taking a single photo.
 *
 *  @return Instance of `DJIShootPhotoStep`.
 */
- (instancetype _Nullable)initWithSingleShootPhoto;

/**
 *  Initialized step for continous photo shooting.
 *
 *  @param count    Photo count.
 *  @param interval Time interval in seconds between shooting photos.
 *
 *  @return Instance of `DJIShootPhotoStep`.
 */
- (instancetype _Nullable)initWithPhotoCount:(int)count timeInterval:(double)interval;

@end

NS_ASSUME_NONNULL_END