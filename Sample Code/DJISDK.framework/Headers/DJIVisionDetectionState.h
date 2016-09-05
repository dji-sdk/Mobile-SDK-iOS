//
//  DJIVisionDetectionState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Distance warning returned by each sector of the front vision system. 
 *  Warning Level 4 is the most serious level.
 */
typedef NS_ENUM (NSInteger, DJIVisionSectorWarning){
    /**
     *  The warning level is invalid. The sector cannot determine depth of the
     *  scene in front of it.
     */
    DJIVisionSectorWarningInvalid,
    /**
     *  The distance between the obstacle detected by the sector and the 
     *  aircraft is over 4 meters.
     */
    DJIVisionSectorWarningLevel1,
    /**
     *  The distance between the obstacle detected by the sector and the
     *  aircraft is between 3 - 4 meters.
     */
    DJIVisionSectorWarningLevel2,
    /**
     *  The distance between the obstacle detected by the sector and the
     *  aircraft is between 2 - 3 meters.
     */
    DJIVisionSectorWarningLevel3,
    /**
     *  The distance between the obstacle detected by the sector and the
     *  aircraft is less than 2 meters.
     */
    DJIVisionSectorWarningLevel4,
    /**
     *  The distance warning is unknown. This warning is returned when an
     *  exception occurs.
     */
    DJIVisionSectorWarningUnknown = 0xFF
};

/**
 *  Distance warning returned by the front vision system. Warning Level 4 is the
 *  most serious level.
 */
typedef NS_ENUM (NSInteger, DJIVisionSystemWarning){
    /**
     *  The warning is invalid. The front vision system cannot determine depth
     *  of the scene in front of it.
     */
    DJIVisionSystemWarningInvalid,
    /**
     *  The distance between the obstacle detected by the vision system and the
     *  aircraft is safe (over 2 meters).
     */
    DJIVisionSystemWarningSafe,
    /**
     *  The distance between the obstacle detected by the vision system and the
     *  aircraft is dangerous (less than 2 meters).
     */
    DJIVisionSystemWarningDangerous,
    /**
     *  The distance warning is unknown. This warning is returned when an
     *  exception occurs.
     */
    DJIVisionSystemWarningUnknown = 0xFF
};

/**
 *  The vision system can see in front of the aircraft with a 70 degree
 *  horizontal field of view (FOV) and 55-degree vertical FOV. The horizontal
 *  FOV is split into four equal sectors, and this class gives the distance and
 *  warning level for one sector.
 */
@interface DJIVisionDetectionSector : NSObject

/**
 *  The detected obstacle distance to the aircraft in meters.
 */
@property(nonatomic, readonly) double obstacleDistanceInMeters;

/**
 *  The warning level based on distance.
 */
@property(nonatomic, readonly) DJIVisionSectorWarning warningLevel;

@end

/**
 * This class gives state information about the vision system and aircraft,
 *  including information from each sector the vision system covers.
 */
@interface DJIVisionDetectionState : NSObject

/**
 *  `YES` if the vision sensor is working.
 */
@property(nonatomic, readonly) BOOL isSensorWorking;

/**
 *  `YES` if the aircraft is braking automatically to avoid collision.
 */
@property(nonatomic, readonly) BOOL isBraking;

/**
 *  Warning level between the obstacle and the aircraft. This is a combination
 *  of warning levels from each sector.
 */
@property(nonatomic, readonly) DJIVisionSystemWarning systemWarning;

/**
 *  The vision system can see in front of the aircraft with a 70 degree
 *  horizontal field of view (FOV) and 55-degree vertical FOV for the Phantom 4.
 *  The horizontal FOV is split into four equal sectors and this array contains
 *  the distance and warning information for each sector. For Phantom 4, the
 *  horizontal FOV is separated into 4 sectors.
 */
@property(nonatomic, readonly) NSArray *_Nonnull detectionSectors;

@end
