//
//  DJISDCardOperation.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

@class DJICameraSDCardInfo;

@protocol DJISDCardOperation <NSObject>

/**
 *  Format SD card.
 *
 *  @param block Remote execute result callback.
 */
-(void) formatSDCard:(DJIExecuteResultBlock)block;

/**
 *  Get SD card information and status.
 *
 *  @param block Remote execute result callback.
 */
-(void) getSDCardInfo:(void(^)(DJICameraSDCardInfo* sdInfo, DJIError* error))block;

@end
