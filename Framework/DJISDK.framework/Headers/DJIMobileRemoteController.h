//
//  DJIMobileRemoteController.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

/**
 *  A simulated remote controller on the mobile device to control the aircraft
 *  when the physical remote controller is absent. The mobile remote controller
 *  only supports Mode 2 control style and flight mode P.
 *
 *  It is supported by Mavic Pro using WiFi.
 */
@interface DJIMobileRemoteController : DJIBaseComponent

/**
 *  Simulates the vertical movement of the left stick, which changes the
 *  aircraft's thrust causing it to raise or lower in elevation. The valid 
 *  range is [-1, 1].
 */
@property (nonatomic, readwrite) float leftStickVertical;
/**
 *  Simulates the horizontal movement of the left stick, which changes the
 *  yaw of the aircraft causing it to rotate horizontally. The valid range
 *  is [-1, 1].
 */
@property (nonatomic, readwrite) float leftStickHorizontal;
/**
 *  Simulates the vertical movement of the right stick, which changes the
 *  the aircraft's pitch causing it to fly forward or backward. The valid
 *  range is [-1, 1].
 */
@property (nonatomic, readwrite) float rightStickVertical;
/**
 *  Simulates the horizontal movement of the right stick, which changes the
 *  the aircraft's roll causing it to fly left or right. The valid range is 
 *  [-1, 1].
 */
@property (nonatomic, readwrite) float rightStickHorizontal;

@end
