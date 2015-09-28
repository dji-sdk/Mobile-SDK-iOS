//
//  DJIPhantom3ProBattery.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <DJISDK/DJIBattery.h>

@class DJIError;

@interface DJIPhantom3ProBattery : DJIBattery

/**
 *  Get battery's cell voltage. The object in cellArray is kind of class DJIBatteryCell
 *
 *  @param block Remote execute result callback.
 */
-(void) getCellVoltagesWithResult:(void(^)(NSArray* cellArray, DJIError* error))block;

@end
