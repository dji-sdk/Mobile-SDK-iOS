//
//  DJIFirmwareManager.h
//  DJISDK
//
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIFoundation.h>
#import <DJISDK/DJIDrone.h>

@interface DJIFirmwarePackage : NSObject

/**
 *  Release date for this firmware package.
 */
@property(nonatomic, readonly) NSDate* date;

/**
 *  Package's version for drone
 */
@property(nonatomic, readonly) NSString* version;

/**
 *  Package version for remote controller
 */
@property(nonatomic, readonly) NSString* rcVersion;

/**
 *  Get version for device from firmware package
 *
 *  @param deviceName Device name see definitation kDJIDeviceXXX
 *
 *  @return Version of device
 */
-(NSString*) versionForDevice:(NSString*)deviceName;

@end

@interface DJIFirmwareManager : NSObject

+(instancetype) defaultManager;

/**
 *  Get firmware packages for drone.
 *
 *  @param type Type of drone.
 *
 *  @return Return firmware packages that contains object with class DJIFirmwarePackage.
 */
-(NSArray*) firmwarePackagesForDrone:(DJIDroneType)type;

@end
