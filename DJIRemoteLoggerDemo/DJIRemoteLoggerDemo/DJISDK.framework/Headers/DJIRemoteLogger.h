//
//  DJIRemoteLogger.h
//  DJILogger
//
//  Created by Dhanush Balachandran on 8/26/15.
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, DJILogLevel) {
    DJILogLevelOff = 0,
    DJILogLevelError,
    DJILogLevelWarn,
    DJILogLevelDebug,
    DJILogLevelInfo,
    DJILogLevelVerbose
    
};

@interface DJIRemoteLogger : NSObject

+(DJILogLevel) currentLogLevel;
+(void) setCurrentLogLevel: (DJILogLevel) level;

//Preferred method to configure the logger
+ (void)configureLoggerWithDeviceId: (NSString*) deviceID URLString: (NSString*) urlString showLogInConsole: (BOOL) showLogInConsole;
+ (void) resetLogger;

+ (void)logWithLevel: (DJILogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ...;

+ (void)logWithLevel: (DJILogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              string:(NSString*)string;


@end

#define DJILogError(frmt, ...)   [DJIRemoteLogger logWithLevel:DJILogLevelError file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format: (frmt), ##__VA_ARGS__]
#define DJILogWarn(frmt, ...)    [DJIRemoteLogger logWithLevel:DJILogLevelWarn file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format: (frmt), ##__VA_ARGS__]
#define DJILogInfo(frmt, ...)    [DJIRemoteLogger logWithLevel:DJILogLevelInfo file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format: (frmt), ##__VA_ARGS__]
#define DJILogDebug(frmt, ...)   [DJIRemoteLogger logWithLevel:DJILogLevelDebug file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format: (frmt), ##__VA_ARGS__]
#define DJILogVerbose(frmt, ...) [DJIRemoteLogger logWithLevel:DJILogLevelVerbose file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__ format: (frmt), ##__VA_ARGS__]