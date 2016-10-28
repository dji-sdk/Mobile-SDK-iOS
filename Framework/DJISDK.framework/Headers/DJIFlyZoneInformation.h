//
//  DJIFlyZoneInformation.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  DJI Fly Zone Information Invalid Timestamp.
 */
extern NSString *const DJIFlyZoneInformationInvalidTimestamp;

/**
 *  An enum class represents the category of fly zone.
 */
typedef NS_ENUM (uint8_t, DJIFlyZoneCategory){
    /**
     *  Warning zones do not restrict flight and are informational to alert the user.
     *  In a warning zone, users should be prompted with a warning message describing the zone.
     */
    DJIFlyZoneCategoryWarning,
    
    /**
     *  Authorization zones restrict flight by default, but can be unlocked by a GEO authorized user.
     */
    DJIFlyZoneCategoryAuthorization,
    
    /**
     *  Restricted zones restrict flight by default and cannot be unlocked by a GEO authorized user.
     *  Users should contact flysafe@dji.com if they have authorization to fly in a restricted zone.
     */
    DJIFlyZoneCategoryRestricted,
    
    /**
     *  Enhanced warning zones restrict flight by default, and can be unlocked using `unlockFlyZones:withCompletion:` without requiring the user to be logged into their DJI account.
     */
    DJIFlyZoneCategoryEnhancedWarning,
    
    /**
     *  Unknown.
     */
    DJIFlyZoneCategoryUnknown = 0xFF
};

/**
 *  An enum class contains the type of the fly zone.
 */
typedef NS_ENUM(uint8_t, DJIFlyZoneType) {
    /**
     *  Airport that cannot be unlocked using GEO system.
     */
    DJIFlyZoneTypeAirport,
    
    /**
     *  Military authorized zone. This cannot be unlocked using the GEO system.
     */
    DJIFlyZoneTypeMilitary,
    
    /**
     *  Special Zone. This cannot be unlocked using the GEO system.
     */
    DJIFlyZoneTypeSpecial,
    
    /**
     *  Commercial airport.
     */
    DJIFlyZoneTypeCommercialAirport,
    
    /**
     *  Private commercial airport.
     */
    DJIFlyZoneTypePrivateCommercialAirport,
    
    /**
     *  Recreational airport.
     */
    DJIFlyZoneTypeRecreationalAirport,
    
    /**
     *  National park.
     */
    DJIFlyZoneTypeNationalPark,
    
    /**
     *  The National Oceanic and Atmospheric Administration.
     */
    DJIFlyZoneTypeNOAA,
    
    /**
     *  Parcel.
     */
    DJIFlyZoneTypeParcel,
    
    /**
     *  Power plant.
     */
    DJIFlyZoneTypePowerPlant,
    
    /**
     *  Prison.
     */
    DJIFlyZoneTypePrison,
    
    /**
     *  School.
     */
    DJIFlyZoneTypeSchool,
    
    /**
     *  Stadium.
     */
    DJIFlyZoneTypeStadium,
    
    /**
     *  Prohibited special use.
     */
    DJIFlyZoneTypeProhibitedSpecialUse,
    
    /**
     *  Restriction special use.
     */
    DJIFlyZoneTypeRestrictedSpecialUse,
    
    /**
     *  Temporary flight restriction.
     */
    DJIFlyZoneTypeTemporaryFlightRestriction,
    
    /**
     *  Class B controlled airspace.
     *  See http://www.dji.com/flysafe/geo-system#notes for more information on the controlled airspace (Class B, C, D, E) in the United States.
     */
    DJIFlyZoneTypeClassBAirSpace,
    
    /**
     *  Class C controlled airspace.
     *  See http://www.dji.com/flysafe/geo-system#notes for more information on the controlled airspace (Class B, C, D, E) in the United States.
     */
    DJIFlyZoneTypeClassCAirSpace,
    
    /**
     *  Class D controlled airspace.
     *  See http://www.dji.com/flysafe/geo-system#notes for more information on the controlled airspace (Class B, C, D, E) in the United States.
     */
    DJIFlyZoneTypeClassDAirSpace,

    /**
     *  Class E Controlled Airspace.
     *  See http://www.dji.com/flysafe/geo-system#notes for more information on the controlled airspace (Class B, C, D, E) in the United States.
     */
    DJIFlyZoneTypeClassEAirSpace,
    
    /**
     *  Airport with unpaved runway.
     */
    DJIFlyZoneTypeUnpavedAirport,
    
    /**
     *  Heliport.
     */
    DJIFlyZoneTypeHeliport,
    
    /**
     *  Unknown.
     */
    DJIFlyZoneTypeUnknown = 0xFF,
};

/**
 *  An enum class contains the shape of the fly zone.
 */
typedef NS_ENUM(uint8_t, DJIFlyZoneShape) {
    /**
     *  Cylinder.
     */
    DJIFlyZoneShapeCylinder,
    
    /**
     *  Truncated cone that has a smaller radius on the ground and larger radius in the air.
     */
    DJIFlyZoneShapeCone,
    
    /**
     *  Unknown.
     */
    DJIFlyZoneShapeUnknown = 0xFF
};

/**
 *  This enum describes whether an aircraft is clear of, near a fly zone.
 */
typedef NS_ENUM(uint8_t, DJIFlyZoneStatus) {
    /**
     *  Aircraft is not within 200 meters of any warning, enhanced warning, authorization or restricted zone.
     */
    DJIFlyZoneStatusClear,
    
    /**
     *  The aircraft is within 200 meters of an authorization or restricted zone.
     */
     DJIFlyZoneStatusNearRestrictedZone,
    
    /**
     *  The aircraft is currently in a warning or enhanced warning zone.
     */
    DJIFlyZoneStatusInWarningZone,
    
    /**
     * The aircraft is currently in an authorization or restricted zone.
     */
    DJIFlyZoneStatusInRestrictedZone,
    
    /**
     *  Unknown.
     */
    DJIFlyZoneStatusUnknown = 0xFF
};

/**
 * This data structure class contains the geospatial information for the fly zone.
 */
@interface DJIFlyZoneInformation : NSObject

/**
 *  The fly zone's identifier (required in the unlock process).
 */
@property(nonatomic, readonly) NSUInteger flyZoneID;

/**
 *  The name of the fly zone.
 */
@property(nonatomic, readonly) NSString* name;

/**
 *  The coordinate of the fly zone's center.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 *  The radius of the fly zone in meters. If the fly zone is a truncated cone, then this radius is the bottom of the cone.
 */
@property(nonatomic, readonly) double radius;

/**
 *  The timestamp of when the flight warning or flight restriction begins. This is used for temporary flight restrictions. 
 *  It is UTC time in format YYYY-MM-DD hh:mm:ss. When the time is not available from the server, `DJIFlyZoneInformationInvalidTimestamp` will be returned.
 */
@property(nonatomic, readonly) NSString* startTime;

/**
 *  The timestamp of when the flight warning or flight restriction ends.
 *  It is UTC time in format YYYY-MM-DD hh:mm:ss. When the time is not available from the server, `DJIFlyZoneInformationInvalidTimestamp` will be returned.
 */
@property(nonatomic, readonly) NSString* endTime;

/**
 *  The timestamp when the fly zone is unlocked. 
 *  It is UTC time in format YYYY-MM-DD hh:mm:ss. When the fly zone is locked, `DJIFlyZoneInformationInvalidTimestamp` will be returned.
 */
@property(nonatomic, readonly) NSString* unlockStartTime;

/**
 *  The timestamp the unlocked zone expires. 
 *  It is UTC time in format YYYY-MM-DD hh:mm:ss. When the fly zone is locked, `DJIFlyZoneInformationInvalidTimestamp` will be returned.
 */
@property(nonatomic, readonly) NSString* unlockEndTime;

/**
 *  The type of the fly zone.
 */
@property(nonatomic, readonly) DJIFlyZoneType type;

/**
 *  The shape of the fly zone.
 */
@property(nonatomic, readonly) DJIFlyZoneShape shape;

/**
 *  The category of the fly zone.
 */
@property(nonatomic, readonly) DJIFlyZoneCategory category;

@end
