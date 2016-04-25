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
- (void)battery:(DJIBattery *_Nonnull)battery didUpdateState:(DJIBatteryState *_Nonnull)batteryState;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryOverview
/*********************************************************************************/

/**
 *  Provides an overview of a battery - used when multiple batteries are deployed on one product.
 */
@interface DJIBatteryOverview : NSObject

/**
 *  Index of the battery. Index starts from 0.
 *  For Matrice 600, the number 1 battery compartment relates to index 0.
 */
@property(nonatomic, readonly) NSUInteger index;
/**
 *  `YES` if the battery is currently connected to the aircraft.
 */
@property(nonatomic, readonly) BOOL isConnected;
/**
 *  The remaining percentage energy of the battery with range [0,100].
 */
@property(nonatomic, readonly) NSInteger energyRemainingPercent;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryAggregationState
/*********************************************************************************/

/**
 *  Provides a real time summary of the aggregated battery system.
 *  Only supported by M600.
 */
@interface DJIBatteryAggregationState : NSObject

/**
 *  The number of currently connected batteries.
 */
@property(nonatomic, readonly) NSUInteger numberOfConnectedBatteries;

/**
 *  Returns the overview of batteries in the battery group. When a battery is not connected, the `isConnected` property is `NO` and the `energyRemainingPercent` is zero.
 *  For Matrice 600, there are 6 elements in `batteryOverviews`.
 */
@property(nonatomic, readonly) NSArray<DJIBatteryOverview *> *_Nullable batteryOverviews;
/**
 *  Returns the current voltage (mV) provided by the battery group.
 */
@property(nonatomic, readonly) NSInteger currentVoltage;
/**
 *  Returns the real time current draw through the batteries. A negative value means the batteries are being discharged.
 */
@property(nonatomic, readonly) NSInteger currentCurrent;
/**
 *  Returns the the total amount of energy, in mAh (milliamp hours), stored in the batteries when the batteries are fully charged.
 */
@property(nonatomic, readonly) NSInteger fullChargeEnergy;
/**
 *  Returns the remaining energy stored in the batteries in mAh (milliamp hours).
 */
@property(nonatomic, readonly) NSInteger currentEnergy;
/**
 *  Returns the percentage of energy left in the battery group with range [0 - 100].
 */
@property(nonatomic, readonly) NSInteger energyRemainingPercent;
/**
 *  Returns the highest temperature (in Centigrade) among the batteries in the group, with a range [-128 to 127].
 */
@property(nonatomic, readonly) NSInteger highestBatteryTemperature;
/**
 *  `YES` if one of the batteries in the group is disconnected. When it is `YES`, the aircraft is not allowed to take off.
 */
@property(nonatomic, readonly) BOOL batteryDisconnected;
/**
 *  `YES` if there is significant difference between the voltage (above 1.5V) of two batteries. When it is `YES`, the aircraft is not allowed to take off.
 */
@property(nonatomic, readonly) BOOL voltageDifferenceDetected;
/**
 *  `YES` if one of the batteries in the group has cells with low voltage. When it is `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL lowCellVoltageDetected;
/**
 *  `YES` if one of the batteries in the group has damaged cells. When it is `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL hasDamagedCell;
/**
 *  `YES` if one of the batteries in the group has a firmware version different from the others. When it is `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL firmwareDifferenceDetected;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryAggregationDelegate
/*********************************************************************************/

/**
 *  This protocol provides a delegate method for you to update the battery's current state.
 */
@protocol DJIBatteryAggregationDelegate <NSObject>

@optional

/**
 *  Updates the aggregate information of the batteries.
 *  Only supported by M600.
 *
 *  @param batteryState The battery's state.
 */
- (void)batteriesDidUpdateState:(DJIBatteryAggregationState *_Nonnull)batteryState;

@end

/*********************************************************************************/
#pragma mark - DJIBattery
/*********************************************************************************/

/**
 *  This class manages the battery's information and real-time status of the connected product.
 */
@interface DJIBattery : DJIBaseComponent

/**
 *  Sets the delegate to receive the battery aggregation information.
 *  Only supported by Matrice 600.
 *
 *  @param delegate The delegate that will receive the aggregation information.
 */
+ (void)setAggregationDelegate:(id<DJIBatteryAggregationDelegate>_Nullable)delegate;
/**
 *  Gets the delegate that receives the battery aggregation state. It is only useful when the aircraft has multiple batteries.
 *  Only supported by Matrice 600.
 *
 *  @return the delegate receives the battery aggregation state.
 */
+ (id<DJIBatteryAggregationDelegate>_Nullable)aggregationDelegate;

/**
 *  Returns the index of the battery. It is useful when the aircraft has multiple batteries. Index starts from 0. For products with only one battery, the index is 0.
 *  For Matrice 600, there are printed numbers on the battery boxes. DJIBattery instance with index 0 corresponds to battery compartment number 1.
 */
@property(nonatomic, readonly) NSUInteger index;

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

/*********************************************************************************/
#pragma mark Get battery properties and status
/*********************************************************************************/

/**
 *  Gets the battery's history. The DJI battery keeps the history for
 *  the past 30 days. The `history` variable in the block stores objects of type
 *  `DJIBatteryWarningInformation`. Call the `isSmartBattery` method before using this method.
 *
 *  Not supported by Osmo.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getWarningInformationRecordsWithCompletion:(void (^_Nonnull)(NSArray<DJIBatteryWarningInformation *> *_Nullable history, NSError *_Nullable error))block;

/**
 *  Gets the battery's current state, which is one of seven battery states that
 *  can be found at the top of DJIBattery.h. Call the `isSmartBattery` method before using this method.
 *  Not supported by Osmo.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCurrentWarningInformationWithCompletion:(void (^_Nonnull)(DJIBatteryWarningInformation *_Nullable state, NSError *_Nullable error))block;

/**
 *  Gets the battery's cell voltages. The `cellArray` variable stores `DJIBatteryCell` objects. Since the Inspire 1 battery has 6 cells, `cellArray`
 *  has 6 objects: one for each battery cell.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCellVoltagesWithCompletion:(void (^_Nonnull)(NSArray<DJIBatteryCell *> *_Nullable cellArray, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Battery self discharge
/*********************************************************************************/

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
- (void)getSelfDischargeDayWithCompletion:(void (^_Nonnull)(uint8_t day, NSError *_Nullable error))block;

@end

NS_ASSUME_NONNULL_END
