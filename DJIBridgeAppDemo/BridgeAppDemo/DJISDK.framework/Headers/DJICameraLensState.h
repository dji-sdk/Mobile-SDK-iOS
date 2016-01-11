//
//  DJICameraLensState.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJICameraSettingsDef.h"

/**
 *  The type of the installed lens.
 */
typedef NS_ENUM (NSUInteger, DJILensType) {
    /**
     *  The lens supports Auto Focus.
     *  For this type, DJI SDK can control the focus point.
     */
    DJILensTypeAF,
    /**
     *  The lens supports only Manual Focus.
     *  For this type, DJI SDK cannot control the focus point.
     */
    DJILensTypeMF,
    /**
     *  The lens type is unkown.
     */
    DJILensTypeUnknown
};

/**
 *  The focusing status of the camera's lens.
 */
typedef NS_ENUM (NSUInteger, DJICameraLensFocusStatus) {
    /**
     *  The lens is idle. No focus target has been set.
     */
    DJICameraLensFocusStatusIdle = 0x00,
    /**
     *  The lens is focusing to the target.
     */
    DJICameraLensFocusStatusFocusing,
    /**
     *  The lens succeeds to fucus on the target.
     */
    DJICameraLensFocusStatusSuccess,
    /**
     *  The lens fails to fucus on the target.
     *  It happens when the target is too near or the camera cannot distinguish the object to focus (e.g. a white w
     *  wall).
     */
    DJICameraLensFocusStatusFailure
};

/**
 *  This class contains the information about the lens' current state, including lens type, focus status, focus mode,
 *  focus assistant state and AF switch state.
 *
 *  Supported only by X5 camera.
 */
@interface DJICameraLensState : NSObject

/**
 *  If the Lens is installed on the camera or not.
 */
@property(nonatomic, readonly) BOOL isLensInstalled;

/**
 *  The installed lens type. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) DJILensType lensType;

/**
 *  The AF switch on the lens is on. If the lens is not installed, the value is undefined.
 *  If the property is YES, user can call setLensFocusMode and control the focal point with the SDK.
 */
@property(nonatomic, readonly) BOOL isAFSwitchOn;

/**
 *  The current focus mode. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) DJICameraLensFocusMode focusMode;

/**
 *  The focus status of the lens. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) DJICameraLensFocusStatus focusStatus;

/**
 *  If the focus assistant enabled for Manual focus mode. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantEnabledForMF;

/**
 *  If the focus assistant enabled for Auto focus mode. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantEnabledForAF;

/**
 *  If the focus target is zooming out. If the lens is not installed, the value is undefined.
 */
@property(nonatomic, readonly) BOOL isFocusAssistantWorking;

@end
