//
//  DJIVersionManager.m
//  DJISdkDemo
//
//  Created by Ares on 15/9/14.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "DJIVersionManager.h"
#import "NSString+VersionCompare.h"

@interface DJIVersionManager ()

@property(nonatomic, strong) DJIGetVersionResultHandler resultHandler;

@property(nonatomic, strong) NSMutableDictionary* versionDict;

@end

@implementation DJIVersionManager

-(id) initWithDrone:(DJIDrone*)drone
{
    self = [super init];
    if (self) {
        self.versionDict = [[NSMutableDictionary alloc] init];
        _drone = drone;
    }
    return self;
}

-(void) getVersionWithResult:(void(^)(NSString* version, DJIError* error))result
{
    self.resultHandler = result;
    if (self.resultHandler) {
        if (!self.drone) {
            self.resultHandler(nil, NewErrorObject(ERR_InvalidParameter));
            return;
        }
        
        [self getVersion];
    }
}


-(void) getVersion
{
    __weak DJIVersionManager* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [weakSelf.drone.camera getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceCamera];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceCamera];
            }
        }];
        
        [weakSelf.drone.mainController getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceMainController];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceMainController];
            }
        }];
        
        [weakSelf.drone.gimbal getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceGimbal];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceGimbal];
            }
        }];
        
        [weakSelf.drone.smartBattery getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceBattery];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceBattery];
            }
        }];
        
        [weakSelf.drone.remoteController getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceRemoteController];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceRemoteController];
            }
        }];
        
        [weakSelf.drone.imageTransmitter getVersionWithResult:^(NSString *version, DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                [weakSelf getVersionCompleted:version forDevice:kDJIDeviceImageTransmitter];
            }
            else
            {
                [weakSelf getVersionError:error forDevice:kDJIDeviceImageTransmitter];
            }
        }];
    });
}

-(void) getVersionError:(DJIError*)error forDevice:(NSString*)device
{
    [self dispatchVersion:nil withError:error];
}

-(void) getVersionCompleted:(NSString*)version forDevice:(NSString*)device
{
    if (version) {
        [self.versionDict setObject:version forKey:device];
        
        if (self.versionDict.allValues.count >= 6) {
            [self compareVersions];
        }
    }
    else
    {
        [self getVersionError:NewErrorObject(ERR_InvalidData) forDevice:device];
    }
    
}

-(void) dispatchVersion:(NSString*)version withError:(DJIError*)error
{
    DJIGetVersionResultHandler handler = self.resultHandler;
    self.resultHandler = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (handler) {
            handler(version, error);
        }
    });
}

-(void) compareVersions
{
    NSArray* packages = [[DJIFirmwareManager defaultManager] firmwarePackagesForDrone:self.drone.droneType];
    if (packages && packages.count > 0) {
        for (int i = 0; i < packages.count; i++) {
            DJIFirmwarePackage* pack = [packages objectAtIndex:i];
            BOOL ret = [self matchVersionWithPackage:pack];
            if (ret) {
                [self dispatchVersion:pack.version withError:NewErrorObject(ERR_Succeeded)];
            }
        }
    }
}

-(BOOL) matchVersionWithPackage:(DJIFirmwarePackage*)package
{
    BOOL isMatch = YES;
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceCamera];
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceMainController];
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceGimbal];
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceBattery];
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceRemoteController];
    isMatch &= [self isVersionMatch:package forDevice:kDJIDeviceImageTransmitter];
    return isMatch;
}

-(BOOL) isVersionMatch:(DJIFirmwarePackage*)package forDevice:(NSString*)device
{
    NSString* localVersion = [self.versionDict objectForKey:device];
    NSString* packageVersion = [package versionForDevice:device];
    NSComparisonResult result = [localVersion compareToVersion:packageVersion];
    if (result == NSOrderedSame || result == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
