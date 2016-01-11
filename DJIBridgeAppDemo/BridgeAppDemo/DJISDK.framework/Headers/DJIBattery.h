//
//  DJIBattery.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIBattery;

/*********************************************************************************/
#pragma mark - DJIBatteryState
/*********************************************************************************/

/**
 *  The DJIBatteryState is used to keep track the real-time state of the battery.
 */
@interface DJIBatteryState : NSObject

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

@end

/*********************************************************************************/
#pragma mark - DJIBatteryWarningInformation
/*********************************************************************************/
/**
 *  The DJIBatteryWarningInformation is used to keep a record of the unusual status of the battery
 *  for the past 30 days. For all the properties below, please continuously check these values to ensure the
 *  battery's state is normal. If any of the properties below that indicate an issue with the battery, we
 *  reccomend notifying the user.
 *
 *  NOTE: No automatic action will be taken if any of the properties below return true,
 *  which is why it becomes imperative the user is notified of the issue.
 *
 *  All states are not supported by OSMO.
 */
@interface DJIBatteryWarningInformation : NSObject

/**
 *  YES if battery should be discharged due to a current overload.
 */
@property(nonatomic, readonly) BOOL dischargeDueToCurrentOverload;

/**
 *  YES if battery should be discharged due to being over heated.
 */
@property(nonatomic, readonly) BOOL dischargeDueToOverHeating;

/**
 *  YES if battery should be discharged due to a low temperature.
 */
@property(nonatomic, readonly) BOOL dischargeDueToLowTemperature;

/**
 *  YES if battery should be discharged due to it being short circuited.
 */
@property(nonatomic, readonly) BOOL dischargeDueToShortCircuit;

/**
 *  YES if battery has been configured to be discharged over a specific
 *  number of days. Once the battery is fully charged again, the battery will discharge
 *  over the number of days set here again. This process is cyclical.
 */
@property(nonatomic, readonly) BOOL customDischargeEnabled;

/**
 *  Returns the index at which one of the cells in the battery is below the normal voltage.
 *  The Phantom 3 Series have 4 cell batteries. The Inspire series and M100 have
 *  6 cell batteries.
 *
 */
@property(nonatomic, readonly) uint8_t underVoltageBatteryCellIndex;

/**
 *  Returns the index at which one of the cells in the battery is damaged. The first cell has index 1.
 *  The Phantom 3 Series have 4 cell batteries. The Inspire series and M100 have
 *  6 cell batteries.
 */
@property(nonatomic, readonly) uint8_t damagedBatteryCellIndex;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryCell
/*********************************************************************************/

/**
 *  Class that contains battery cell voltage data.
 */
@interface DJIBatteryCell : NSObject

/**
 *  Returns the voltage (mV) of the current battery cell.
 */
@property(nonatomic, readonly) uint16_t voltage;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryDelegate
/*********************************************************************************/

/**
 *  The protocol provides a delegate method for you to update battery's current state.
 */
@protocol DJIBatteryDelegate <NSObject>

@optional

/**
 *  Updates the battery's current state.
 *
 *  @param battery      Battery that has updated state.
 *  @param batteryState The battery's state.
 */
- (void)battery:(DJIBattery *)battery didUpdateState:(DJIBatteryState *)batteryState;

@end

/*********************************************************************************/
#pragma mark - DJIBattery
/*********************************************************************************/

/**
 *  This class manages the battery's information and real-time status of the connected product.
 */
@interface DJIBattery : DJIBaseComponent

/**
 *  Returns the number of battery cells.
 */
@property(nonatomic, readonly) NSUInteger numberOfCell;

/**
 *  Delegate that recevies the updated state pushed by the battery.
 */
@property(nonatomic, weak) id<DJIBatteryDelegate> delegate;

/**
 *  YES if battery is a smart battery.
 */
- (BOOL)isSmartBattery;

//-----------------------------------------------------------------
#pragma mark Get battery properties and status
//-----------------------------------------------------------------
/**
 *  Gets the battery's history. The DJI battery keeps the history for
 *  the past 30 days. The NSArray named history in the block holds objects of type
 *  DJIBatteryWarningInformation. Need to check isSmartBattery method before using this method.
 *  Not supported by OSMO.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getWarningInformationRecordsWithCompletion:(void (^)(NSArray<DJIBatteryWarningInformation *> *history, NSError *_Nullable error))block;

/**
 *  Gets the battery's current state, which is one of seven battery states, which
 *  can be found at the top of DJIBattery.h. Need to check isSmartBattery method before using this method.
 *  Not supported by OSMO.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCurrentWarningInformationWithCompletion:(void (^)(DJIBatteryWarningInformation *state, NSError *_Nullable error))block;

/**
 *  Gets the battery's cell voltages. The NSArray named cellArray holds objects of type
 *  DJIBatteryCell. For the Inspire 1, since the battery has 6 cells, the array cellArray
 *  will have 6 objects, one for each battery cell.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCellVoltagesWithCompletion:(void (^)(NSArray<DJIBatteryCell *> *cellArray, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Battery self discharge
//-----------------------------------------------------------------
/**
 *  Sets battery's custom self-discharge configuration in the range of [1, 10] days.
 *  For example, if the value for 'day' is set to 10, the battery will discharge over
 *  the course of 10 days. Need to check isSmartBattery method before using this method.
 *  Not supported by OSMO.
 *
 *  @param day   Day for self-discharge
 *  @param block Remote execution result error block.
 */
- (void)setSelfDischargeDay:(uint8_t)day withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the battery's custom self-discharge configuration. Need to check isSmartBattery method before using this method.
 *  Not supported by OSMO.
 *
 *  @param result Remote execution result error block.
 */
- (void)getSelfDischargeDayWithCompletion:(void (^)(uint8_t day, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
