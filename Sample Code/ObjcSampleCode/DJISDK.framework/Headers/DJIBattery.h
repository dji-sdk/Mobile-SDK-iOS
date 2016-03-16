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
 *  Returns the the total amount of energy, in mAh (milliamp hours), stored in the battery
 *  when the battery is fully charged. The energy of the battery at full charge changes over time
 *  as the battery continues to get used. Over time, as the battery continues to be recharged, the
 *  value of fullChargeEnergy will decrease.
 */
@property(nonatomic, readonly) NSInteger fullChargeEnergy;

/**
 *  Returns the remaining energy stored in the battery in mAh (milliamp hours).
 */
@property(nonatomic, readonly) NSInteger currentEnergy;

/**
 *   Returns the current battery voltage (mV).
 */
@property(nonatomic, readonly) NSInteger currentVoltage;

/**
 *  Returns the real time current draw of the battery (mA). A negative value means the battery is being discharged, and a positive value means it is being charged.
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
 *  Returns the temperature of battery in Centigrade, with a range [-128 to 127].
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
 *  The DJIBatteryWarningInformation is used to keep a record of any unusual status for the battery
 *  in the past 30 days. For all the properties below, monitor these values frequently to ensure the
 *  battery's state is normal. If any of the properties below indicate there is an issue with the battery, we
 *  reccomend notifying the user.
 *
 *  NOTE: No automatic action will be taken if any of the properties below return `YES`,
 *  which is why it is imperative the user is notified of the issue.
 *
 *  These states are not supported by Osmo.
 */
@interface DJIBatteryWarningInformation : NSObject

/**
 *  `YES` if the battery should be discharged due to a current overload.
 */
@property(nonatomic, readonly) BOOL dischargeDueToCurrentOverload;

/**
 *  `YES` if the battery should be discharged due to being over heated.
 */
@property(nonatomic, readonly) BOOL dischargeDueToOverHeating;

/**
 *  `YES` if the battery should be discharged due to a low temperature.
 */
@property(nonatomic, readonly) BOOL dischargeDueToLowTemperature;

/**
 *  `YES` if the battery should be discharged due to being short circuited.
 */
@property(nonatomic, readonly) BOOL dischargeDueToShortCircuit;

/**
 *  `YES` if the battery has been configured to be discharged over a specific
 *  number of days. Once the battery is fully recharged, the battery will again discharge
 *  over the number of days set here. This process is cyclical.
 */
@property(nonatomic, readonly) BOOL customDischargeEnabled;

/**
 *  Returns the index at which one of the cells in the battery is below the normal voltage.
 *  The first cell has an index of 1.
 *  The Phantom 3 Series have 4 cell batteries. The Inspire series and M100 have
 *  6 cell batteries.
 *
 */
@property(nonatomic, readonly) uint8_t underVoltageBatteryCellIndex;

/**
 *  Returns the index at which one of the cells in the battery is damaged. The first cell has an index of 1.
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
 *  This protocol provides a delegate method for you to update the battery's current state.
 */
@protocol DJIBatteryDelegate <NSObject>

@optional

/**
 *  Updates the battery's current state.
 *
 *  @param battery      Battery having an updated state.
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
 *  Delegate that receives the updated state pushed by the battery.
 */
@property(nonatomic, weak) id<DJIBatteryDelegate> delegate;

/**
 *  `YES` if the battery is a smart battery.
 */
- (BOOL)isSmartBattery;

//-----------------------------------------------------------------
#pragma mark Get battery properties and status
//-----------------------------------------------------------------
/**
 *  Gets the battery's history. The DJI battery keeps the history for
 *  the past 30 days. The `history` variable in the block stores objects of type
 *  `DJIBatteryWarningInformation`. Call the `isSmartBattery` method before using this method.
 *
 *  Not supported by Osmo.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getWarningInformationRecordsWithCompletion:(void (^)(NSArray<DJIBatteryWarningInformation *> *history, NSError *_Nullable error))block;

/**
 *  Gets the battery's current state, which is one of seven battery states that
 *  can be found at the top of DJIBattery.h. Call the `isSmartBattery` method before using this method.
 *  Not supported by Osmo.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCurrentWarningInformationWithCompletion:(void (^)(DJIBatteryWarningInformation *state, NSError *_Nullable error))block;

/**
 *  Gets the battery's cell voltages. The `cellArray` variable stores `DJIBatteryCell` objects. Since the Inspire 1 battery has 6 cells, `cellArray`
 *  has 6 objects: one for each battery cell.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCellVoltagesWithCompletion:(void (^)(NSArray<DJIBatteryCell *> *cellArray, NSError *_Nullable error))block;

//-----------------------------------------------------------------
#pragma mark Battery self discharge
//-----------------------------------------------------------------
/**
 *  Sets the battery's custom self-discharge configuration in the range of [1, 10] days.
 *  For example, if the value for `day` is `10`, the battery will discharge over
 *  the course of 10 days. Call the `isSmartBattery` method before using this method.
 *  Not supported by Osmo.
 *
 *  @param day   Day for self-discharge
 *  @param block Remote execution result error block.
 */
- (void)setSelfDischargeDay:(uint8_t)day withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the battery's custom self-discharge configuration. Call the `isSmartBattery` method before using this method.
 *  Not supported by Osmo.
 *
 *  @param result Remote execution result error block.
 */
- (void)getSelfDischargeDayWithCompletion:(void (^)(uint8_t day, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
