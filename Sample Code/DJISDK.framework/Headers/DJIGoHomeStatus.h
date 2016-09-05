//
//  DJIGoHomeStatus.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJIGoHomeStatus : NSObject

    /**
     *  The estimated remaining time, in seconds, it will take the aircraft to go home with a 10% battery buffer remaining.
     *  This time includes landing the aircraft.
     */
@property (nonatomic, assign) NSUInteger remainingFlightTime;
    
    /**
     *  The estimated time, in seconds, needed for the aircraft to go home from its
     *  current location.
     */
@property (nonatomic, assign) NSUInteger timeNeededToGoHome;
    
    /**
     *  The estimated time, in seconds, needed for the aircraft to land from its current
     *  height. The time calculated will be for the aircraft to land, moving
     *  straight down, from its current height.
     */
@property (nonatomic, assign) NSUInteger timeNeededToLandFromCurrentHeight;
    
    /**
     *  The estimated battery percentage, in the range of [0 - 100], needed for the aircraft
     *  to go home and have 10% battery remaining. This includes landing of the aircraft.
     */
@property (nonatomic, assign) NSUInteger batteryPercentageNeededToGoHome;
    
    /**
     *  The battery percentage, in the range of [0 - 100], needed for the aircraft
     *  to land from its current height. The battery percentage needed will be for
     *  the aircraft to land, moving straight down, from its current height.
     */
@property (nonatomic, assign) NSUInteger batteryPercentageNeededToLandFromCurrentHeight;
    
    /**
     *  The maximum radius, in meters, an aircraft can fly from its home location
     *  and still make it all the way back home based on certain factors including
     *  altitude, distance, battery, etc. If the aircraft goes out farther than the
     *  max radius, it will fly as far back home as it can and land.
     */
@property (nonatomic, assign) float maxRadiusAircraftCanFlyAndGoHome;
    
    /**
     *  Returns whether the aircraft is requesting to go home. If the value of
     *  `aircraftShouldGoHome` is YES and the user does not respond after 10 seconds,
     *  the aircraft will automatically go back to its home location. This can be canceled
     *  at any time with the `cancelGoHome` method (which will also clear `aircraftShouldGoHome`). It is recommended
     *  that an alert view is shown to the user when `aircraftShouldGoHome` returns YES.
     *  During this time, the Remote Controller will beep.
     *
     *  The flight controller calculates whether the aircraft should go home based
     *  on the aircraft's altitude, distance, battery, etc.
     *
     *  The two main situations in which `aircraftShouldGoHome` will return YES are if the
     *  aircraft's battery is too low or if the aircraft has flown too far away.
     */
@property (nonatomic, assign) BOOL aircraftShouldGoHome;

@end
