//
//  DJIRTK.h
//  DJISDK
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIBaseProduct.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIRTK;
@class DJIRTKState;

/**
 *  This enum defines the positioning solution the system is currently using.
 */
typedef NS_ENUM (NSInteger, DJIRTKPositioningSolution){
    /**
     *  No positinging solution. This can be caused by an insufficient number of sattelites in view, an insufficient
     *  amount of time to lock onto the satellites, or a loss in communication link between the mobile station and base station.
     */
    DJIRTKPositioningSolutionNone,
    /**
     *  RTK point positioning.
     */
    DJIRTKPositioningSolutionSinglePoint,
    /**
     *  Float solution positioning.
     */
    DJIRTKPositioningSolutionFloat,
    /**
     *  Fixed-point solution positioning. The supplied location information will be the most accurate in this mode.
     */
    DJIRTKPositioningSolutionFixedPoint,
};

/**
 *  This protocol provides a delegate method to update the RTK state.
 */
@protocol DJIRTKDelegate <NSObject>

@optional
/**
 *  Callback function that updates the RTK state data.
 *
 *  @param rtk    Instance of the RTK.
 *  @param state Current state of the RTK.
 */
- (void)rtk:(DJIRTK *_Nonnull)rtk didUpdateRTKState:(DJIRTKState *_Nonnull)state;

@end

/**
 *  Single RTK receiver information. Each receiver is connected to a single antenna.
 */
@interface DJIRTKReceiverInfo : NSObject

/**
 *  `YES` if constellation is supported. The European and American version of RTK supports GPS and GLONASS, while the Asia Pacific version supports GPS and BeiDou.
 */
@property(nonatomic, readonly) BOOL isConstellationSupported;

/**
 *  Valid satellite count for this receiver.
 */
@property(nonatomic, readonly) NSInteger satelliteCount;

@end

/**
 *  This class holds the state of the RTK system including position, positioning solution and receiver information.
 */
@interface DJIRTKState : NSObject

/**
 *  RTK error if there is any. Returns `nil` when RTK is normal.
 */
@property(nonatomic, readonly) NSError *_Nullable error;

/**
 *  The positioning solution informs the quality of the position. The most accurate position is obtained when a fixed point solution is returned.
 */
@property(nonatomic, readonly) DJIRTKPositioningSolution solution;

/**
 *  Mobile station (aircraft) receiver 1 GPS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver1GPSInfo;

/**
 *  Mobile station (aircraft) receiver 1 BeiDou info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver1BeiDouInfo;

/**
 *  Mobile station (aircraft) receiver 1 GLONSS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver1GLONASSInfo;

/**
 *  Mobile station (aircraft) receiver 2 GPS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver2GPSInfo;

/**
 *  Mobile station (aircraft) receiver 2 BeiDou info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver2BeiDouInfo;

/**
 *  Mobile station (aircraft) receiver 2 GLONASS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull mobileStationReceiver2GLONASSInfo;

/**
 *  Base station receiver GPS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull baseStationReceiverGPSInfo;

/**
 *  Base station receiver BeiDou info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull baseStationReceiverBeiDouInfo;

/**
 *  Base station receiver GLONASS info.
 */
@property(nonatomic, readonly) DJIRTKReceiverInfo *_Nonnull baseStationReceiverGLONASSInfo;

/**
 * Location information of the mobile station's receiver 1 antenna.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D mobileStationAntenna1Location;

/**
 * Altitude of the mobile station's receiver 1 antenna relative to sea level. Units are meters.
 */
@property(nonatomic, readonly) float mobileStationAntenna1Altitude;

/**
 * Location of the base station in coordinates in degrees.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D baseStationLocation;

/**
 * Altitude of the base station above sea level in meters.
 */
@property(nonatomic, readonly) float baseStationAltitude;

/**
 *  Heading relative to True Noth defined by the vector formed from Antenna 2 to Antenna 1 on the mobile station. Unit is degrees.
 */
@property(nonatomic, readonly) float heading;

/**
 *  `YES` if heading value is valid. Heading is not valid when a satellite fix hasn't been obtained.
 */
@property(nonatomic, readonly) BOOL isHeadingValid;

/**
 *  Whether the RTK is enabled.
 */
@property(nonatomic, readonly) BOOL isRTKEnabled;

@end

/**
 *  Real Time Kinematic
 */
@interface DJIRTK : NSObject

/**
 *  DJI RTK delegate.
 */
@property(nonatomic, weak) id<DJIRTKDelegate> delegate;

/**
 *  'YES' if RTK is connected to the aircraft.
 */
@property(nonatomic, readonly) BOOL isConnected;

/**
 *  Enables RTK positioning. Disable RTK when in poor signal environments where incorrect positioning information might might controlling the aircraft difficult.
 */
- (void)setRTKEnabled:(BOOL)enable withCompletion:(DJICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END