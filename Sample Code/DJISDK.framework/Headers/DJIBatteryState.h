//
//  DJIBatteryState.h
//  DJISDK
//
//  Copyright © 2016, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Battery cell voltage level threshold. Different thresholds will initiate
 *  different aircraft behaviors or operations.
 *  Level 3 is the lowest level.
 *  It is only supported when the connected product is stand-alone A3.
 */
typedef NS_ENUM (uint8_t, DJIBatteryCellVoltageLevel){
    /**
     *  The cell voltage is at a safe level. The aircraft can fly normally.
     */
    DJIBatteryCellVoltageLevel0,
    /**
     *  The cell voltage is equal to or lower than threshold Level 1. At this
     *  level the Level 1 operation will be executed.
     *  The threshold value and operation for Level 1 can be configured by the
     *  user.
     */
    DJIBatteryCellVoltageLevel1,
    /**
     *  The cell voltage is equal to or lower than threshold Level 2. At this
     *  level the Level 2 operation will be executed.
     *  The threshold value and operation for Level 2 can be configured by the
     *  user.
     */
    DJIBatteryCellVoltageLevel2,
    /**
     *  The cell voltage is equal to or lower than Level 3. At this level, the
     *  aircraft will start landing.
     *  The threshold for Level 3 cannot be configured by the user and is fixed
     *  at 3400mV.
     */
    DJIBatteryCellVoltageLevel3,
    /**
     *  Unknown
     */
    DJIBatteryCellVoltageLevelUnknown = 0xFF
};


/**
 *  Defines aircraft operation when the cell voltage is low.
 *  It is only supported when the connected product is stand-alone A3.
 */
typedef NS_ENUM (uint8_t, DJIBatteryLowCellVoltageOperation){
    /**
     *  LED lights go into warning mode
     */
    DJIBatteryLowCellVoltageOperationLEDWarning,
    /**
     *  Return-to-Home
     */
    DJIBatteryLowCellVoltageOperationGoHome,
    /**
     *  Land aircraft immediately
     */
    DJIBatteryLowCellVoltageOperationLand,
    /**
     *  Unknown
     */
    DJIBatteryLowCellVoltageOperationUnknown = 0xFF
};

/*********************************************************************************/
#pragma mark - DJIBatteryState
/*********************************************************************************/

/**
 *  `DJIBatteryState` is used to keep track of the real-time state of the
 *  battery. It is supported by both smart and non-smart batteries. However for
 *  non-smart batteries, only some of the properties are valid:
 *  - When the connected product is A3, only `currentVoltage` and
 *    `cellVoltageLevel` are valid.
 *  - When the connected product is A2, only `currentVoltage` is valid.
 */
@interface DJIBatteryState : NSObject

/**
 *  Returns the total amount of energy, in mAh (milliamp hours), stored in
 *  the battery when the battery is fully charged. The energy of the battery at
 *  full charge changes over time as the battery continues to get used. Over
 *  time, as the battery continues to be recharged, the value of 
 *  `fullChargeEnergy` will decrease.
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
 *  Returns the real time current draw of the battery (mA). A negative value
 *  means the battery is being discharged, and a positive value means it is
 *  being charged.
 */
@property(nonatomic, readonly) NSInteger currentCurrent;

/**
 *  Returns the percentage of remaining lifetime value of the battery. The range
 *  of this value is [0 - 100].
 */
@property(nonatomic, readonly) NSInteger lifetimeRemainingPercent;

/**
 *  Returns the percentage of battery energy left. The range of this value is
 *  [0 - 100].
 */
@property(nonatomic, readonly) NSInteger batteryEnergyRemainingPercent;

/**
 *  Returns the temperature of battery in Centigrade, with a range [-128 to 127].
 */
@property(nonatomic, readonly) NSInteger batteryTemperature;

/**
 *  Returns the total number of discharges the battery has gone through over its
 *  lifetime. The total number of discharges includes discharges that happen
 *  through normal use and discharges that are manually set.
 */
@property(nonatomic, readonly) NSInteger numberOfDischarge;

/**
 *  Current cell voltage level of the battery. 
 *  It is only supported when the connected product is stand-alone A3.
 */
@property(nonatomic, readonly) DJIBatteryCellVoltageLevel cellVoltageLevel; 

/**
 *  `YES` if the battery is being charged. 
 *  It is only supported by Osmo Mobile.
 */
@property(nonatomic, readonly) BOOL isBeingCharged;

@end

/*********************************************************************************/
#pragma mark - DJIBatteryWarningInformation
/*********************************************************************************/

/**
 *  The DJIBatteryWarningInformation is used to keep a record of any unusual
 *  status for the battery in the past 30 discharges. For all the properties
 *  below, monitor these values frequently to ensure the battery's state is
 *  normal. If any of the properties below indicate there is an issue with the
 *  battery, we reccomend notifying the user.
 *
 *  NOTE: No automatic action will be taken if any of the properties below 
 *  return `YES`, which is why it is imperative the user is notified of the issue.
 *
 *  These states are not supported by Osmo.
 */
@interface DJIBatteryWarningInformation : NSObject

/**
 *  `YES` if the battery should be discharged due to a current overload.
 */
@property(nonatomic, readonly) BOOL currentOverload;

/**
 *  `YES` if the battery has over heated.
 */
@property(nonatomic, readonly) BOOL overHeating;

/**
 *  `YES` if the battery has experienced a temperature that is too low.
 */
@property(nonatomic, readonly) BOOL lowTemperature;

/**
 *  `YES` if the battery has been or is short circuited.
 */
@property(nonatomic, readonly) BOOL shortCircuit;

/**
 *  `YES` if the battery has been configured to be discharged over a specific
 *  number of days. Once the battery is fully recharged, the battery will again
 *  discharge over the number of days set here. This process is cyclical.
 */
@property(nonatomic, readonly) BOOL customDischargeEnabled;

/**
 *  Returns the index at which one of the cells in the battery is below the
 *  normal voltage. The first cell has an index of 1.
 *  The Phantom 3 Series have 4 cell batteries. The Inspire series and M100 have
 *  6 cell batteries.
 *
 */
@property(nonatomic, readonly) uint8_t underVoltageBatteryCellIndex;

/**
 *  Returns the index at which one of the cells in the battery is damaged. The
 *  first cell has an index of 1. The Phantom 3 Series have 4 cell batteries.
 *  The Inspire series and M100 have 6 cell batteries.
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
#pragma mark - DJIBatteryOverview
/*********************************************************************************/

/**
 *  Provides an overview of a battery - used when multiple batteries are
 *  deployed on one product.
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
 *  Returns the overview of batteries in the battery group. When a battery is
 *  not connected, the `isConnected` property is `NO` and the
 *  `energyRemainingPercent` is zero.
 *  For Matrice 600, there are 6 elements in `batteryOverviews`.
 */
@property(nonatomic, readonly) NSArray<DJIBatteryOverview *> *_Nullable batteryOverviews;
/**
 *  Returns the current voltage (mV) provided by the battery group.
 */
@property(nonatomic, readonly) NSInteger currentVoltage;
/**
 *  Returns the real time current draw through the batteries. A negative value
 *  means the batteries are being discharged.
 */
@property(nonatomic, readonly) NSInteger currentCurrent;
/**
 *  Returns the the total amount of energy, in mAh (milliamp hours), stored in
 *  the batteries when the batteries are fully charged.
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
 *  Returns the highest temperature (in Centigrade) among the batteries in the
 *  group, with a range [-128 to 127].
 */
@property(nonatomic, readonly) NSInteger highestBatteryTemperature;
/**
 *  `YES` if one of the batteries in the group is disconnected. When it is `YES`,
 *  the aircraft is not allowed to take off.
 */
@property(nonatomic, readonly) BOOL batteryDisconnected;
/**
 *  `YES` if there is significant difference between the voltage (above 1.5V) of
 *  two batteries. When it is `YES`, the aircraft is not allowed to take off.
 */
@property(nonatomic, readonly) BOOL voltageDifferenceDetected;
/**
 *  `YES` if one of the batteries in the group has cells with low voltage. When
 *  it is `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL lowCellVoltageDetected;
/**
 *  `YES` if one of the batteries in the group has damaged cells. When it is
 *  `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL hasDamagedCell;
/**
 *  `YES` if one of the batteries in the group has a firmware version different
 *  from the others. When it is `YES`, the aircraft is not allow to take off.
 */
@property(nonatomic, readonly) BOOL firmwareDifferenceDetected;

@end
