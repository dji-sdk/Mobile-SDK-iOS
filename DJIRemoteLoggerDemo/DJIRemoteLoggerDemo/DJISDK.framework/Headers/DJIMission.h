/*
 *  DJI iOS Mobile SDK Framework
 *  DJIMission.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "DJIBaseProduct.h"


#define PROGRESS_END_BOUNDARY   100.0

NS_ASSUME_NONNULL_BEGIN

@interface DJIMissionProgressStatus : NSObject

@property(nonatomic, readonly) NSError* _Nullable error;

@end

@class DJIMission;

/**
 *  Type of the progress.
 */
typedef NS_ENUM(uint8_t, DJIProgressType){
    /**
     * Upload progress.
     */
    DJIProgressTypeUpload,

    /**
     * Executing progress
     */
    DJIProgressTypeExecute,
    /**
     * Download progress
     */
    DJIProgressTypeDownload,

    /**
     * Custom mission progress
     */
    DJIProgressTypeCustom,
};

/**
 * Returns the progress status from 0.0 to PROGRESS_END_BOUNDARY which is defined as 100.0
 */
typedef void (^_Nullable DJIMissionProgressHandler)(DJIProgressType type, float progress);


typedef void (^_Nullable DJIDownloadMissionCompletionBlock)(DJIMission* _Nullable newMission, NSError* _Nullable error);



@interface DJIMission : NSObject

/**
 *  Whether or not the mission's parameters are valid for execution. If this property
 *  returns NO, then the attempt to startMission will have failed.
 *
 *  @attention The result of 'isValid' just show whether the mission's local parameters are valid. Not for all execution condition.
 *
 */
@property(nonatomic, readonly) BOOL isValid;

/**
 *  Show failure reason for checking parameters of mission. Value will be set after calling 'isValid'.
 *
 */
@property(nonatomic, readonly) NSString* failureReason;


-(BOOL) isPausable;


@end

NS_ASSUME_NONNULL_END
