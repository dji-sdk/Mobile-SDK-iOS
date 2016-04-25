//
//  DJISDK.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Project version number for DJISDK.
 */
FOUNDATION_EXPORT double DJISDKVersionNumber;

/**
 *  Project version string for DJISDK.
 */
FOUNDATION_EXPORT const unsigned char DJISDKVersionString[];

// In this header, import all the public headers of your framework using statements like #import <DJISDK/PublicHeader.h>

/*********************************************************************************/
#pragma mark - SDK Manager
/*********************************************************************************/
#import <DJISDK/DJISDKManager.h>

/*********************************************************************************/
#pragma mark - Products
/*********************************************************************************/
#import <DJISDK/DJIAircraft.h>
#import <DJISDK/DJIHandheld.h>
#import <DJISDK/DJIBaseProduct.h>

/*********************************************************************************/
#pragma mark - Diagnostics
/*********************************************************************************/
#import <DJISDK/DJIDiagnostics.h>

/*********************************************************************************/
#pragma mark - Utility
/*********************************************************************************/
#import <DJISDK/DJIParamCapability.h>
#import <DJISDK/DJIParamCapabilityMinMax.h>

/*********************************************************************************/
#pragma mark - Components
/*********************************************************************************/
//-----------------------------------------------------------------
#pragma mark FlightController
//-----------------------------------------------------------------
#import <DJISDK/DJIFlightController.h>
#import <DJISDK/DJIFlightControllerCurrentState.h>
#import <DJISDK/DJIFlightLimitation.h>
#import <DJISDK/DJILandingGear.h>
#import <DJISDK/DJICompass.h>
#import <DJISDK/DJIIntelligentFlightAssistant.h>
#import <DJISDK/DJIIMUState.h>
#import <DJISDK/DJIRTK.h>
#import <DJISDK/DJISimulator.h>

//-----------------------------------------------------------------
#pragma mark RemoteController
//-----------------------------------------------------------------
#import <DJISDK/DJIRemoteController.h>

//-----------------------------------------------------------------
#pragma mark Camera
//-----------------------------------------------------------------
#import <DJISDK/DJICamera.h>
#import <DJISDK/DJICameraSettingsDef.h>
#import <DJISDK/DJICameraPlaybackState.h>
#import <DJISDK/DJICameraSystemState.h>
#import <DJISDK/DJICameraLensState.h>
#import <DJISDK/DJICameraSDCardState.h>
#import <DJISDK/DJICameraSSDState.h>
#import <DJISDK/DJICameraParameters.h>
#import <DJISDK/DJIMediaManager.h>
#import <DJISDK/DJIMedia.h>
#import <DJISDK/DJIPlaybackManager.h>

//-----------------------------------------------------------------
#pragma mark Gimbal
//-----------------------------------------------------------------
#import <DJISDK/DJIGimbal.h>

//-----------------------------------------------------------------
#pragma mark Battery
//-----------------------------------------------------------------
#import <DJISDK/DJIBattery.h>

//-----------------------------------------------------------------
#pragma mark AirLink
//-----------------------------------------------------------------
#import <DJISDK/DJIAirLink.h>
#import <DJISDK/DJILBAirLink.h>
#import <DJISDK/DJIWiFiLink.h>
#import <DJISDK/DJIAuxLink.h>
#import <DJISDK/DJISignalInformation.h>

//-----------------------------------------------------------------
#pragma mark Handheld Controller
//-----------------------------------------------------------------
#import <DJISDK/DJIHandheldController.h>

/*********************************************************************************/
#pragma mark - Abstract Classes
/*********************************************************************************/
#import <DJISDK/DJIBaseProduct.h>
#import <DJISDK/DJIBaseComponent.h>

/*********************************************************************************/
#pragma mark - Missions
/*********************************************************************************/
#import <DJISDK/DJIMissionManager.h>
#import <DJISDK/DJIMission.h>
#import <DJISDK/DJIWaypoint.h>
#import <DJISDK/DJIWaypointMission.h>
#import <DJISDK/DJIHotPointMission.h>
#import <DJISDK/DJIFollowMeMission.h>
#import <DJISDK/DJICustomMission.h>
#import <DJISDK/DJIPanoramaMission.h>
#import <DJISDK/DJITapFlyMission.h>
#import <DJISDK/DJIActiveTrackMission.h>

#import <DJISDK/DJIMissionStep.h>
#import <DJISDK/DJIWaypointStep.h>
#import <DJISDK/DJIHotpointStep.h>
#import <DJISDK/DJIFollowMeStep.h>
#import <DJISDK/DJITakeoffStep.h>
#import <DJISDK/DJIGoHomeStep.h>
#import <DJISDK/DJIGoToStep.h>
#import <DJISDK/DJIRecordVideoStep.h>
#import <DJISDK/DJIShootPhotoStep.h>
#import <DJISDK/DJIGimbalAttitudeStep.h>
#import <DJISDK/DJIAircraftYawStep.h>

/*********************************************************************************/
#pragma mark - Categories
/*********************************************************************************/
#import <DJISDK/NSError+DJISDK.h>

/*********************************************************************************/
#pragma mark - Remote Logger
/*********************************************************************************/
#import <DJISDK/DJIRemoteLogger.h>