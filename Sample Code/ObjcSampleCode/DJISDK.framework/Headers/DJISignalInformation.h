//
//  DJISignalInformation.h
//  DJISDK
//
//  Copyright © 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class contains signal status of a channel.
 */
@interface DJISignalInformation : NSObject

/**
 *  Signal quality in percent [0, 100].
 */
@property(nonatomic, readonly) int percent;

/**
 *  Signal strength in dBm.
 *
 */
@property(nonatomic, readonly) int power;

@end
