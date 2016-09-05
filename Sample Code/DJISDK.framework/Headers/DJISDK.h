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

/*********************************************************************************/
#pragma mark - SDK Manager
/*********************************************************************************/
#import <DJISDK/DJISDKManager.h>
#import <DJISDK/DJIBluetoothProductConnector.h>
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
#import <DJISDK/DJIFlightControllerKeys.h>
#import <DJISDK/DJIFlightControllerCurrentState.h>
#import <DJISDK/DJIFlightLimitation.h>
#import <DJISDK/DJILandingGear.h>
#import <DJISDK/DJICompass.h>
#import <DJISDK/DJIIntelligentFlightAssistant.h>
#import <DJISDK/DJIVisionDetectionState.h>
#import <DJISDK/DJIIMUState.h>
#import <DJISDK/DJIRTK.h>
#import <DJISDK/DJISimulator.h>
#import <DJISDK/DJICompassCalibrationStatus.h>
#import <DJISDK/DJILandingGearStructs.h>
#import <DJISDK/DJIFlightOrientationMode.h>
#import <DJISDK/DJIFlightControllerBaseTypes.h>
#import <DJISDK/DJISimulatorState.h>
#import <DJISDK/DJIGoHomeStatus.h>


//-----------------------------------------------------------------
#pragma mark RemoteController
//-----------------------------------------------------------------
#import <DJISDK/DJIRemoteControllerBaseTypes.h>
#import <DJISDK/DJIRemoteController.h>
#import <DJISDK/DJIRemoteControllerKeys.h>

//-----------------------------------------------------------------
#pragma mark Camera
//-----------------------------------------------------------------
#import <DJISDK/DJICamera.h>
#import <DJISDK/DJICameraKeys.h>
#import <DJISDK/DJICameraSettingsDef.h>
#import <DJISDK/DJICameraPlaybackState.h>
#import <DJISDK/DJICameraSystemState.h>
#import <DJISDK/DJICameraLensState.h>
#import <DJISDK/DJICameraSDCardState.h>
#import <DJISDK/DJICameraSSDState.h>
#import <DJISDK/DJICameraDisplayNames.h>
#import <DJISDK/DJICameraParameters.h>
#import <DJISDK/DJIMediaManager.h>
#import <DJISDK/DJIMedia.h>
#import <DJISDK/DJIPlaybackManager.h>

//-----------------------------------------------------------------
#pragma mark Gimbal
//-----------------------------------------------------------------
#import <DJISDK/DJIGimbalBaseTypes.h>
#import <DJISDK/DJIGimbal.h>
#import <DJISDK/DJIGimbalKeys.h>
#import <DJISDK/DJIGimbalState.h>
#import <DJISDK/DJIGimbalAdvancedSettingsState.h>

//-----------------------------------------------------------------
#pragma mark Battery
//-----------------------------------------------------------------
#import <DJISDK/DJIBattery.h>
#import <DJISDK/DJIBatteryKeys.h>
#import <DJISDK/DJIBatteryState.h>
//-----------------------------------------------------------------
#pragma mark AirLink
//-----------------------------------------------------------------
#import <DJISDK/DJIAirLink.h>
#import <DJISDK/DJIAirLinkKeys.h>
#import <DJISDK/DJILBAirLink.h>
#import <DJISDK/DJIWiFiLink.h>
#import <DJISDK/DJIAuxLink.h>
#import <DJISDK/DJISignalInformation.h>
#import <DJISDK/DJIAirLinkBaseTypes.h>

//-----------------------------------------------------------------
#pragma mark Handheld Controller
//-----------------------------------------------------------------
#import <DJISDK/DJIHandheldControllerBaseTypes.h>
#import <DJISDK/DJIHandheldController.h>
#import <DJISDK/DJIHandheldControllerKeys.h>

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
#pragma mark - GEO
/*********************************************************************************/
#import <DJISDK/DJIFlyZoneInformation.h>
#import <DJISDK/DJIFlyZoneManager.h>
/*********************************************************************************/
#pragma mark - Categories
/*********************************************************************************/
#import <DJISDK/NSError+DJISDK.h>

/*********************************************************************************/
#pragma mark - Remote Logger
/*********************************************************************************/
#import <DJISDK/DJIRemoteLogger.h>
