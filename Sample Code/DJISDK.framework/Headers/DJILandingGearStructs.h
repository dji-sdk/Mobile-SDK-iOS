//
//  DJILandingGearStructs.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#ifndef DJILandingGearStructs_h
#define DJILandingGearStructs_h

/**
 *  Current state of the Landing Gear.
 */
typedef NS_ENUM (uint8_t, DJILandingGearStatus){
    /**
     *  Landing Gear is in unknown state.
     */
    DJILandingGearStatusUnknown,
    /**
     *  Landing Gear is fully deployed (ready for landing).
     */
    DJILandingGearStatusDeployed,
    /**
     *  Landing Gear is fully retracted (ready for flying).
     */
    DJILandingGearStatusRetracted,
    /**
     *  Landing Gear is deploying (getting ready for landing).
     */
    DJILandingGearStatusDeploying,
    /**
     *  Landing Gear is retracting (getting ready for flying).
     */
    DJILandingGearStatusRetracting,
    /**
     *  Landing Gear is stopped.
     */
    DJILandingGearStatusStopped,
};

/**
 *  Current Mode of the Landing Gear.
 */
typedef NS_ENUM (uint8_t, DJILandingGearMode){
    /**
     *  Landing Gear can be deployed and retracted through function calls.
     *  It is supported by Inspire 1 and Matrice 600.
     */
    DJILandingGearModeNormal,
    /**
     *  Landing Gear is in transport mode (either it is moving into, moving out
     *  of, or stopped in transport position).
     *  It is only supported by Inspire 1.
     */
    DJILandingGearModeTransport,
    /**
     *  Landing Gear automatically transitions between deployed and retracted
     *  depending on altitude. During take-off, the transition point is 1.2m
     *  above ground. After take-off (during flight or when landing), the
     *  transition point is 0.5m above ground.
     *  It is supported by Inspire 1 and Matrice 600.
     */
    DJILandingGearModeAuto,
    /**
     *  Landing Gear is in an unknown mode.
     */
    DJILandingGearModeUnknown,
};


#endif /* DJILandingGearStructs_h */
