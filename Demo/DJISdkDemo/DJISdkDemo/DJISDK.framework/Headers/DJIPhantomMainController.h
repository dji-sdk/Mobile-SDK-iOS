//
//  DJISDKMainController.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIMainController.h>
#import <DJISDK/DJIGroundStation.h>

/**
 *  Phantom main controller's system mode
 */
typedef NS_ENUM(NSInteger, DJIMCSystemMode){
    /**
     *  Phantom mode
     */
    MCSystemMode_Phantom,
    /**
     *  NAZA mode
     */
    MCSystemMode_Naza,
    /**
     *  Unknown
     */
    MCSystemMode_Unknown
};

@interface DJIPhantomMainController : DJIMainController <DJIGroundStation>

/**
 *  Get main controller's system mode.
 *
 *  @param block  Remote execute result
 */
-(void) getMCSystemMode:(void(^)(DJIMCSystemMode mode, DJIError* error))block;

/**
 *  Set smart go home enable.
 *
 *  @param isEnable Enable for smart go home
 *  @param block    Remote execute result callback.
 */
-(void) setSmartGoHomeEnable:(BOOL)isEnable withResult:(DJIExecuteResultBlock)block;

/**
 *  Get smart go home enable.
 *
 *  @param block  Remote execute result callback.
 */
-(void) getSmartGoHomeEnable:(void(^)(BOOL isEnable, DJIError* error))block;

/**
 *  Confirm go home request. use to confirm go home request while the DJIMCSmartGoHome's droneRequestGoHome property is set.
 *
 *  @param block  Remote execute result callback.
 */
-(void) confirmGoHomeReuqest:(DJIExecuteResultBlock)block;

/**
 *  Ignore go home request. use to ingore go home request while the DJIMCSmartGoHome's droneRequestGoHome property is set.
 *
 *  @param block  Remote execute result callback.
 */
-(void) ignoreGoHomeReuqest:(DJIExecuteResultBlock)block;

@end
