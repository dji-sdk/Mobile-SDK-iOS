//
//  DJIBattery.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

/**
 *   DJIBatteryState is used for record the history status of battery. The dji's battery could keep the state in latest 30 days.
 */
@interface DJIBatteryState : NSObject
/**
 *  Over current in discharge.
 */
@property(nonatomic, readonly) BOOL dischargeOverCurrent;
/**
 *  Over heat in discharge.
 */
@property(nonatomic, readonly) BOOL dischargeOverHeat;
/**
 *  Low temperature in discharge.
 */
@property(nonatomic, readonly) BOOL dischargeLowTemperature;
/**
 *  Short cut in discharge.
 */
@property(nonatomic, readonly) BOOL dischargeShortCut;
/**
 *  Self-discharge in storage.
 */
@property(nonatomic, readonly) BOOL selfDischarge;
/**
 *  Cell Under voltage.
 */
@property(nonatomic, readonly) uint8_t underVoltageCellIndex;
/**
 *  Damaged cell index.
 */
@property(nonatomic, readonly) uint8_t damagedCellIndex;

@end

/**
 *  Description The battery cell
 */
@interface DJIBatteryCell : NSObject

/**
 *  The voltage battery cell.
 */
@property(nonatomic, readonly) uint16_t voltage;

-(id) initWithVolgate:(uint16_t)voltage;

@end

@interface DJIBattery : DJIObject

/**
 *  The battery's design volume (mAh)
 */
@property(nonatomic) NSInteger designedVolume;

/**
 *  The battery's full charge volume (mAh)
 */
@property(nonatomic) NSInteger fullChargeVolume;

/**
 *  The current electricity volume of battery (mAh)
 */
@property(nonatomic) NSInteger currentElectricity;

/**
 *  The current voltage of battery (mV)
 */
@property(nonatomic) NSInteger currentVoltage;

/**
 *  The current current of battery (mA), The negative value is indicate that the battery is in discharge
 */
@property(nonatomic) NSInteger currentCurrent;

/**
 *  Remain life percentage of battery.
 */
@property(nonatomic) NSInteger remainLifePercent;

/**
 *  Remain power percentage of battery.
 */
@property(nonatomic) NSInteger remainPowerPercent;

/**
 *  The temperature of battery between -128 to 127 (Centigrade).
 */
@property(nonatomic) NSInteger batteryTemperature;

/**
 *  The total number of discharge of battery.
 */
@property(nonatomic) NSInteger numberOfDischarge;

/**
 *  Get battery's firmware version
 *
 *  @param block Remote execute result callback.
 */
-(void) getVersionWithResult:(void(^)(NSString* version, DJIError* error))block;

/**
 *  Update battery's information once, if Succeeded, the property value of battery will be update.
 *
 *  @param block Remote exeucte result
 */
-(void) updateBatteryInfo:(DJIExecuteResultBlock)block;

@end
