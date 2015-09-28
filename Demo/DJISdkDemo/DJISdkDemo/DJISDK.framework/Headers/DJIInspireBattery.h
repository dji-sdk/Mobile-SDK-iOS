//
//  DJIInspireBattery.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <DJISDK/DJIBattery.h>

/**
 *  Description DJIInspireBattery is one type of dji battery. the designed volume is 4500mAh, 22.2V
 */
@interface DJIInspireBattery : DJIBattery

/**
 *  Get battery's history state, The dji's battery could keep the state in latest 30 days. Object in 'history' parameters is kind of class DJIBatteryState.
 *
 *  @param result Remote execute result.
 */
-(void) getBatteryHistoryState:(void(^)(NSArray* history, DJIError* error))result;

/**
 *  Get battery's current state.
 *
 *  @param result Remote execute result.
 */
-(void) getBatteryCurrentState:(void (^)(DJIBatteryState* state, DJIError *))result;

/**
 *  Set battery's self-discharge day.
 *
 *  @param day    Day for self-discharge
 *  @param result Remote execute result
 */
-(void) setBatterySelfDischargeDay:(uint8_t)day withResult:(DJIExecuteResultBlock)result;

/**
 *  Get battery self-discharge day
 *
 *  @param result Remote execute result
 */
-(void) getBatterySelfDischargeDayWithResult:(void(^)(uint8_t day, DJIError* error))result;

/**
 *  Get battery's cell voltage. The object in 'cellArray' is kind of class DJIBatteryCell
 *
 *  @param block Remote execute result
 */
-(void) getCellVoltagesWithResult:(void(^)(NSArray* cellArray, DJIError* error))block;

@end
