//
//  DJIRemoteLogger.h
//  DJISDK
//
//  Copyright © 2015, DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  The DJI Remote Log levels.
 */
typedef NS_ENUM(NSUInteger, DJILogLevel) {
    /**
     *  Remote Log level off.
     */
    DJILogLevelOff = 0,
    /**
     *  Remote Log level Error.
     */
    DJILogLevelError,
    /**
     *  Remote Log level Warn.
     */
    DJILogLevelWarn,
    /**
     *  Remote Log level Debug.
     */
    DJILogLevelDebug,
    /**
     *  Remote Log level Info.
     */
    DJILogLevelInfo,
    /**
     *  Remote Log level Verbose.
     */
    DJILogLevelVerbose
    
};

/**
 *  This class provides methods for you to get information about the current log level. It also contains methods to configure the logger.
 *
 */
@interface DJIRemoteLogger : NSObject

/**
 *  Returns the current Log level.
 */
+ (DJILogLevel)currentLogLevel;

/**
 *  Set the current level of remote log
 */
+ (void)setCurrentLogLevel:(DJILogLevel)level;

/**
 *  Preferred method to configure the logger
 */
+ (void)configureLoggerWithDeviceId:(NSString *)deviceID URLString:(NSString *)urlString showLogInConsole:(BOOL)showLogInConsole;

/**
 *  Reset Remote Logger
 */
+ (void)resetLogger;

/**
 *  Log with level, file, function, line and format.
 */
+ (void)logWithLevel:(DJILogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ...;

/**
 *  Log with level, file, function, line and string.
 */
+ (void)logWithLevel:(DJILogLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              string:(NSString *)string;


@end

#define DJILogError(frmt, ...)   [DJIRemoteLogger logWithLevel : DJILogLevelError file : __FILE__ function : __PRETTY_FUNCTION__ line : __LINE__ format : (frmt), ## __VA_ARGS__]
#define DJILogWarn(frmt, ...)    [DJIRemoteLogger logWithLevel : DJILogLevelWarn file : __FILE__ function : __PRETTY_FUNCTION__ line : __LINE__ format : (frmt), ## __VA_ARGS__]
#define DJILogInfo(frmt, ...)    [DJIRemoteLogger logWithLevel : DJILogLevelInfo file : __FILE__ function : __PRETTY_FUNCTION__ line : __LINE__ format : (frmt), ## __VA_ARGS__]
#define DJILogDebug(frmt, ...)   [DJIRemoteLogger logWithLevel : DJILogLevelDebug file : __FILE__ function : __PRETTY_FUNCTION__ line : __LINE__ format : (frmt), ## __VA_ARGS__]
#define DJILogVerbose(frmt, ...) [DJIRemoteLogger logWithLevel : DJILogLevelVerbose file : __FILE__ function : __PRETTY_FUNCTION__ line : __LINE__ format : (frmt), ## __VA_ARGS__]