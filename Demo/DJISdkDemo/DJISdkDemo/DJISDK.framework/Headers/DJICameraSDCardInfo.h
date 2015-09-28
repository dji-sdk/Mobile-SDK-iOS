//
//  DJICameraSDCardInfo.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provide SD card general informations and status
 */
@interface DJICameraSDCardInfo : NSObject

/**
 *  The SD card has error.
 */
@property(nonatomic, readonly) BOOL hasError;

/**
 *  The SD card is read only.
 */
@property(nonatomic, readonly) BOOL readOnly;

/**
 *  The SD card's format is invalid.
 */
@property(nonatomic, readonly) BOOL invalidFormat;

/**
 *  The SD card is formated.
 */
@property(nonatomic, readonly) BOOL isFormated;

/**
 *  The SD card is formating
 */
@property(nonatomic, readonly) BOOL isFormating;

/**
 *  The SD card is full.
 */
@property(nonatomic, readonly) BOOL isFull;

/**
 *  Whether the SD card is a valid card.
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 *  Whether the SD card is inserted into the camera.
 */
@property(nonatomic, readonly) BOOL isInserted;

/**
 *  Total size of the SD card.
 */
@property(nonatomic, readonly) int totalSize;

/**
 *  Remain size of the SD card.
 */
@property(nonatomic, readonly) int remainSize;

/**
 *  The available count for taking photo.
 */
@property(nonatomic, readonly) int availableCaptureCount;

/**
 *  Time available for recording. Supported in Inspire 1/Phantom3 professional
 */
@property(nonatomic, readonly) int availableRecordingTime;

@end
