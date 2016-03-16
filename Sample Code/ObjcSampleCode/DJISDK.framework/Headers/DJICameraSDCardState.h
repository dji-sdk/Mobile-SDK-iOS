//
//  DJICameraSDCardState.h
//  DJISDK
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/*********************************************************************************/
#pragma mark - DJICameraSDCardState
/*********************************************************************************/

/**
 *  This class provides the SD card's general information and current status.
 *
 */
@interface DJICameraSDCardState : NSObject

/**
 *  Yes if the SD card is initializing. Note that if the SD card is initializing, the value for other properties in `DJICameraSDCardState` is undefined.
 */
@property(nonatomic, readonly) BOOL isInitializing;

/**
 *  YES if there is an SD card error.
 */
@property(nonatomic, readonly) BOOL hasError;

/**
 *  YES if the SD card is read-only.
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
 *  YES if the SD card is verified as genuine. The SD card is not valid if it is fake,
 *  which can be a problem if the SD card was purchased by a non-reputable retailer.
 */
@property(nonatomic, readonly) BOOL isVerified;

/**
 *  YES if the SD card is inserted in the camera.
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
 *  on the SD card.
 */
@property(nonatomic, readonly) int availableRecordingTimeInSeconds;

@end
