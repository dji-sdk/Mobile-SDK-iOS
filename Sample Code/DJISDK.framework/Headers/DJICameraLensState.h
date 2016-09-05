//
//  DJICameraLensState.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJICameraSettingsDef.h>

/**
 *  This class contains information about the lens' current state, including
 *  lens type, focus status, focus mode, focus assistant state, and Auto Focus
 *  (AF) switch state.
 *
 *  Supported only by X5 camera and X5R camera.
 */
@interface DJICameraLensState : NSObject

/**
 *  Determines if the Lens is installed on the camera.
 */
@property(nonatomic, readonly) BOOL isLensInstalled;

/**
 *  The installed lens type. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) DJILensType lensType;

/**
 *  The Auto Focus (AF) switch on the lens is on. If the lens is not installed,
 *  the value is undefined. If the property is YES, the user can call
 *  `setLensFocusMode` and control the focal point with the SDK.
 */
@property(nonatomic, readonly) BOOL isAFSwitchOn;

/**
 *  The current focus mode. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) DJICameraLensFocusMode focusMode;

/**
 *  The focus status of the lens. If the lens is not installed, the value is
 *  undefined.
 */
@property(nonatomic, readonly) DJICameraLensFocusStatus focusStatus;

/**
 *  If the focus assistant enabled for Manual focus mode. If the lens is not
 *  installed, the value is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantEnabledForMF;

/**
 *  If the focus assistant enabled for Auto focus mode. If the lens is not
 *  installed, the value is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantEnabledForAF;

/**
 *  If the focus target is zooming out. If the lens is not installed, the value
 *  is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantWorking;

@end
