//
//  DJIFlightOrientationMode.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#ifndef DJIFlightOrientationMode_h
#define DJIFlightOrientationMode_h

/*********************************************************************************/
#pragma mark - DJIFlightOrientationMode
/*********************************************************************************/

/**
 *  Tells the aircraft how to interpret flight commands for forward, backward, left and right.
 *  See the <i>Flight Controller User Guide</i> for more information.
 */
typedef NS_ENUM (uint8_t, DJIFlightOrientationMode){
    /**
     * The aircraft should move relative to a locked course heading.
     */
    DJIFlightOrientationModeCourseLock,
    /**
     * The aircraft should move relative radially to the Home Point.
     */
    DJIFlightOrientationModeHomeLock,
    /**
     *  The aircraft should move relative to the front of the aircraft.
     */
    DJIFlightOrientationModeDefaultAircraftHeading,
};

#endif /* DJIFlightOrientationMode_h */
