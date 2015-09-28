//
//  DJIPhantom3ProRemoteController.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

@interface DJIPhantom3ProRemoteController : DJIRemoteController

/**
 *  Set RC's wheel control the gimbal's pitch speed
 *
 *  @param speed Speed of control gimbal. value should be in range [0, 100]
 *  @param block Remote execute result.
 */
-(void) setRCWheelControlGimbalSpeed:(uint8_t)speed withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC's wheel control gimbal's speed
 *
 *  @param block Remote execute result.
 */
-(void) getRCWheelControlGimbalSpeedWithResult:(void(^)(uint8_t speed, DJIError* error))block;

/**
 *  Set RC's wheel that on the top left will control which direction(pitch or roll or yaw) of gimbal.
 *
 *  @param direction Gimbal's direction control by the wheel
 *  @param block     Remote execute result.
 */
-(void) setRCControlGimbalDirection:(DJIRCGimbalControlDirection)direction withResult:(DJIExecuteResultBlock)block;

/**
 *  Get RC control gimbal's direction
 *
 *  @param block Remote execute.
 */
-(void) getRCControlGimbalDirectionWithResult:(void(^)(DJIRCGimbalControlDirection direction, DJIError* error))block;

/**
 *  Set custom button index. The index is used by user to record user settings
 *
 *  @param index1 Custom button1's index
 *  @param index2 Custom button2's index
 *  @param block  Remote execute result
 */
-(void) setRCCustomButton1Index:(uint8_t)index1 customButtonIndex2:(uint8_t)index2 withResult:(DJIExecuteResultBlock)block;

/**
 *  Get custom button's index settings
 *
 *  @param block Remote execute result
 */
-(void) getRCCustomButtonIndexWithResult:(void(^)(uint8_t index1, uint8_t index2, DJIError* error))block;


@end
