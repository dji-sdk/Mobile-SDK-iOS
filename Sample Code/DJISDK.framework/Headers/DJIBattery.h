//
//  DJIBattery.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIBaseComponent.h>
#import <DJISDK/DJIBatteryState.h>

NS_ASSUME_NONNULL_BEGIN

@class DJIBattery;

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
 *  This class manages the battery's information and real-time status of the
 *  connected product.
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
 *  Gets the delegate that receives the battery aggregation state. It is only
 *  useful when the aircraft has multiple batteries.
 *  Only supported by Matrice 600.
 *
 *  @return the delegate receives the battery aggregation state.
 */
+ (id<DJIBatteryAggregationDelegate>_Nullable)aggregationDelegate;

/**
 *  Returns the index of the battery. It is useful when the aircraft has 
 *  multiple batteries. Index starts from 0. For products with only one battery,
 *  the index is 0.
 *  For Matrice 600, there are printed numbers on the battery boxes. DJIBattery
 *  instance with index 0 corresponds to battery compartment number 1.
 */
@property(nonatomic, readonly) NSUInteger index;

/**
 *  Returns the number of battery cells.
 */
@property(nonatomic, readonly) NSUInteger numberOfCells;

/**
 *  Delegate that receives the updated state pushed by the battery.
 */
@property(nonatomic, weak) id<DJIBatteryDelegate> delegate;

/**
 *  `YES` if the battery is a smart battery. When the connected battery is a DJI
 *  smart battery, more information can be obtained by communicating with the
 *  battery.
 */
- (BOOL)isSmartBattery;

/*********************************************************************************/
#pragma mark Get battery properties and status
/*********************************************************************************/

/**
 *  Gets the battery's history. The DJI battery keeps the history for
 *  the past 30 days. The `history` variable in the block stores objects of type
 *  `DJIBatteryWarningInformation`.
 *
 *  Not supported by Osmo and non-smart batteries.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getWarningInformationRecordsWithCompletion:(void (^_Nonnull)(NSArray<DJIBatteryWarningInformation *> *_Nullable history, NSError *_Nullable error))block;

/**
 *  Gets the battery's current state, which is one of seven battery states that
 *  can be found at the top of DJIBattery.h. Call the `isSmartBattery` method
 *  before using this method.
 *
 *  Not supported by Osmo and non-smart batteries.
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCurrentWarningInformationWithCompletion:(void (^_Nonnull)(DJIBatteryWarningInformation *_Nullable state, NSError *_Nullable error))block;

/**
 *  Gets the battery's cell voltages. The `cellArray` variable stores
 *  `DJIBatteryCell` objects. Since the Inspire 1 battery has 6 cells,
 *  `cellArray` has 6 objects: one for each battery cell.
 *
 *  Supported by all smart batteries including Osmo. 
 *
 *  @param block Remote execution result callback block.
 */
- (void)getCellVoltagesWithCompletion:(void (^_Nonnull)(NSArray<DJIBatteryCell *> *_Nullable cellArray, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Battery self discharge
/*********************************************************************************/

/**
 *  Sets the battery's custom self-discharge configuration in the range of
 *  [1, 10] days. For example, if the value for `day` is `10`, the battery will
 *  discharge over the course of 10 days. Call the `isSmartBattery` method 
 *  before using this method.
 *
 *  Not supported by Osmo and non-smart batteries.
 *
 *  @param day   Day for self-discharge
 *  @param block Remote execution result error block.
 */
- (void)setSelfDischargeDay:(uint8_t)day withCompletion:(DJICompletionBlock)block;

/**
 *  Gets the battery's custom self-discharge configuration. Call the
 *  `isSmartBattery` method before using this method.
 *
 *  Not supported by Osmo and non-smart batteries.
 *
 *  @param block Remote execution result error block.
 */
- (void)getSelfDischargeDayWithCompletion:(void (^_Nonnull)(uint8_t day, NSError *_Nullable error))block;

/*********************************************************************************/
#pragma mark Stand-alone A3 Non-smart Battery
/*********************************************************************************/
/**
 *  When the connected battery is not a smart battery, the user needs to set the
 *  number of cells manually. The flight controller uses the number of cells and
 *  the cell voltage threshold to determine if the aircraft should go home or
 *  land. The valid range is [3, 12].
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param numberOfCells Number of cells inside the battery.
 *  @param block         Remote execution result error block.
 */
- (void)setNumberOfCells:(NSUInteger)numberOfCells withCompletion:(DJICompletionBlock)block;

/**
 *  Sets the Level 1 cell voltage threshold in mV. When the cell voltage of the
 *  battery is lower than the threshold, Level 1 operation will be executed.
 *  The valid range is [3600, 4000] mV. When the new value is not 100 mV higher
 *  than the Level 2 cell voltage threshold, the Level 2 threshold will be set
 *  to (new value - 100) mV.
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param voltageInmV  Level 1 cell voltage threshold to set.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setLevel1CellVoltageThreshold:(NSUInteger)voltageInmV withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Level 1 cell voltage threshold in mV. When the cell voltage of the
 *  battery is lower than the threshold, Level 1 operation will be executed.
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getLevel1CellVoltageThresholdWithCompletion:(void (^_Nonnull)(NSUInteger voltageInmV, NSError *_Nullable error))completion;

/**
 *  Sets the Level 2 cell voltage threshold in mV. When the cell voltage of the
 *  battery is lower than the threshold, Level 2 cell voltage operation will be
 *  executed.
 *  The valid range is [3500, 3800] mV and must be at least 100 mV lower than the
 *  Level 1 voltage threshold.
 *  It is only supported by stand-alone A3.
 *
 *  @param voltageInmV  Level 2 cell voltage threshold to set.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setLevel2CellVoltageThreshold:(NSUInteger)voltageInmV withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the Level 2 cell voltage threshold in mV. When the cell voltage of the
 *  battery is lower than the threshold, Level 1 operation will be executed.
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getLevel2CellVoltageThresholdWithCompletion:(void (^_Nonnull)(NSUInteger voltageInmV, NSError *_Nullable error))completion;

/**
 *  Sets the operation to be executed when the cell voltage crosses beneath the
 *  Level 1 threshold.
 *  It can only be set when the motors are off.
 *  It is only supported by stand-alone A3.
 *
 *  @param operation    Level 1 operation.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setLevel1CellVoltageOperation:(DJIBatteryLowCellVoltageOperation)operation
                    withCompletion:(DJICompletionBlock)completion;

/**
 *  Gets the operation to be executed when the cell voltage crosses beneath the Level 1
 *  threshold.
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getLevel1CellVoltageOperationWithCompletion:(void (^_Nonnull)(DJIBatteryLowCellVoltageOperation operation, NSError *_Nullable error))completion;

/**
 *  Sets the operation to be executed when the cell voltage is under Level 2
 *  threshold.
 *  It can only be set when motors are off.
 *  It is only supported by stand-alone A3.
 *
 *  @param operation    Level 2 operation.
 *  @param completion   Completion block that receives the setter execution result.
 */
- (void)setLevel2CellVoltageOperation:(DJIBatteryLowCellVoltageOperation)operation
                       withCompletion:(DJICompletionBlock)completion;
/**
 *  Gets the operation to be executed when the cell voltage crosses beneath the
 *  Level 2 threshold.
 *
 *  It is only supported by stand-alone A3.
 *
 *  @param completion Completion block that receives the getter execution result.
 */
- (void)getLevel2CellVoltageOperationWithCompletion:(void (^_Nonnull)(DJIBatteryLowCellVoltageOperation operation, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
