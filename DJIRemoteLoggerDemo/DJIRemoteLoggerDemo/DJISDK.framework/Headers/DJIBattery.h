/*
 *  DJI iOS Mobile SDK Framework
 *  DJIBattery.h
 *
 *  Copyright (c) 2015, DJI.
 *  All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/*********************************************************************************/
#pragma mark - DJIBatteryState
/*********************************************************************************/

/**
 *  The DJIBatteryState interface is used to keep a record of the status of the battery
 *  for the past 30 days. For all the properties below, other than selfDischarge, which
 *  lets the user configure how often they would like to discharge the battery, please
 *  continuously check these values to ensure the battery's state is normal. If any of the
 *  properties below that indicate an issue with the battery, we reccomend notifying the user.
 *
 *  NOTE: No automatic action will be taken if any of the properties below return true,
 *  which is why it becomes imperative the user is notified of the issue.
 *
 */

/**/

@interface DJIBatteryState : NSObject

/**
 *  Whether or not the battery should be discharged due to a current overload.
 */
@property(nonatomic, readonly) BOOL dischargeDueToCurrentOverload;

/**
 *  Whether or not the battery should be discharged due to being over heated.
 */
@property(nonatomic, readonly) BOOL dischargeDueToOverHeating;

/**
 *  Whether or not the battery should be discharged due to a low temperature.
 */
@property(nonatomic, readonly) BOOL dischargeDueToLowTemperature;

/**
 *  Whether or not the battery should be discharged due to it being short circuited.
 */
@property(nonatomic, readonly) BOOL dischargeDueToShortCircuit;

/**
 *  Whether or not the battery has been configured to be discharged over a specific
 *  number of days. Once the battery is fully charged again, the battery will discharge
 *  over the number of days set here again. This process is cyclical. Property only
 *  supported for Inspire 1.
 *
 */
@property(nonatomic, readonly) BOOL customDischargeEnabled;

/**
 *  Returns the index at which one of the cells in the battery is below the normal voltage.
 *  The Phatom 3 Advanced & Professional both have 4 cells in the battery. The Inspire 1 and M100 have
 *  6 cells in the battery.
 *
 */
@property(nonatomic, readonly) uint8_t underVoltageBatteryCellIndex;

/**
 *  Returns the index at which one of the cells in the battery is damaged. The Phatom 3 Advanced
 *  & Professional both have 4 cells in the battery. The Inspire 1 has 6 cells in the battery.
 *
 */
@property(nonatomic, readonly) uint8_t damagedBatteryCellIndex;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryCell
/*********************************************************************************/

@interface DJIBatteryCell : NSObject

/**
 *  Returns the voltage (mV) of the current battery cell.
 */
@property(nonatomic, readonly) uint16_t voltage;

@end

/*********************************************************************************/
#pragma mark - DJIBattery
/*********************************************************************************/

@interface DJIBattery : DJIBaseComponent

/**
 *  Returns the designed energy (mAh - milliamp hours) of the total amount of energy stored in
 *  the battery, which is the volume of the battery when it is brand new.
 */
@property(nonatomic, readonly) NSInteger designedEnergy;

/**
 *  Returns the volume (mAh - milliamp hours) of the total amount of energy stored in the battery
 *  when the battery is fully charged. The volume of the battery at full charge changes over time
 *  as the battery continues to get used. Over time, as the battery continues to get charged, the
 *  value of fullChargeEnergy will decrease.
 */
@property(nonatomic, readonly) NSInteger fullChargeEnergy;

/**
 *  Returns the remaining energy stored in the battery (mAh - milliamp hours).
 */
@property(nonatomic, readonly) NSInteger currentEnergy;

/**
 *   Returns the current battery voltage (mV).
 */
@property(nonatomic, readonly) NSInteger currentVoltage;

/**
 *  Returns the real time current draw of the battery (mA). A negative value means the battery is being discharged,
 *  while positive means it's being charged.
 */
@property(nonatomic, readonly) NSInteger currentCurrent;

/**
 *  Returns the percentage of remaining lifetime value of the battery. The range of this
 *  value is [0 - 100].
 *
 */
@property(nonatomic, readonly) NSInteger lifetimeRemainingPercent;

/**
 *  Returns the percentage of battery energy left. The range of this value is [0 - 100].
 */
@property(nonatomic, readonly) NSInteger batteryEnergyRemainingPercent;

/**
 *  Returns the temperature of battery in Centigrade, with the range [-128 to 127].
 */
@property(nonatomic, readonly) NSInteger batteryTemperature;

/**
 *  Returns the total number of discharges the battery has gone through over its lifetime.
 *  The total number of discharges includes discharges that happen through normal use and
 *  discharges that are manually set.
 */
@property(nonatomic, readonly) NSInteger numberOfDischarge;

/**
 *  Returns the number of battery cells.
 */
@property(nonatomic, readonly) NSUInteger numberOfCell;

//-----------------------------------------------------------------
#pragma mark Get battery properties and status
//-----------------------------------------------------------------
/**
 *  Updates the battery's information once, if the method is called without an error. If
 *  the method is called successfully, all of the properties in the DJIBattery interface
 *  will be updated.
 *
 *  @param block Remote exeucte result
 */
-(void) updateBatteryInfoWithCompletion:(DJICompletionBlock)block;

/**
 *  Gets the battery's history. The DJI battery keeps the history for
 *  the past 30 days. The NSArray named history in the block holds objects of type
 *  DJIBatteryState.
 *
 */
-(void) getBatteryHistoryStateWithCompletion:(void(^)(NSArray<DJIBatteryState*> * history, NSError * _Nullable error))block;

/**
 *  Gets the battery's current state, which is one of seven battery states, which
 *  can be found at the top of DJIBattery.h.
 *
 *  @param block Remote execution result callback block.
 */
-(void) getBatteryCurrentStateWithCompletion:(void (^)(DJIBatteryState* state, NSError * _Nullable error))block;

/**
 *  Gets the battery's cell voltages. The NSArray named cellArray holds objects of type
 *  DJIBatteryCell. For the Inspire 1, since the battery has 6 cells, the array cellArray
 *  will have 6 objects, one for each battery cell.
 *
 *  @param block Remote execution result callback block.
 */
-(void) getCellVoltagesWithCompletion:(void(^)(NSArray<DJIBatteryCell *> * cellArray, NSError * _Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Battery self discharge
//-----------------------------------------------------------------
/**
 *  Sets battery's custom self-discharge configuration in the range of [0, 255] days.
 *  For example, if the value for 'day' is set to 10, the battery will discharge over
 *  the course of 10 days.
 *
 *  @param day   Day for self-discharge
 *  @param block Remote execution result error block.
 */
-(void) setBatterySelfDischargeDay:(uint8_t)day withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the battery's custom self-discharge configuration.
 *
 *  @param result Remote execution result error block.
 */
-(void) getBatterySelfDischargeDayWithCompletion:(void(^)(uint8_t day, NSError * _Nullable error))block;

@end

NS_ASSUME_NONNULL_END
