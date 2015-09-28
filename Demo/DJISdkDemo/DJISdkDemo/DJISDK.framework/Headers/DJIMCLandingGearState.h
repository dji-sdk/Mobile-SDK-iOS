//
//  DJIMCLandingGearState.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIMainControllerDef.h>

/**
 *  The aircraft's landing gear state
 */
@interface DJIMCLandingGearState : NSObject

/**
 *  Is landing gear protect function opened. The landing gear protect function is that the landing gear will automatically put down while the dron is landing.
 */
@property(nonatomic, readonly) BOOL isLandingGearProtectOpened;

/**
 *  Landing gear status
 */
@property(nonatomic, readonly) DJIMCLandingGearStatus landingGearStatus;

@end
