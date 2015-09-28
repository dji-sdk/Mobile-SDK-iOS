//
//  DJIVersionManager.h
//  DJISdkDemo
//
//  Created by Ares on 15/9/14.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

typedef void (^DJIGetVersionResultHandler)(NSString* version, DJIError* error);

@interface DJIVersionManager : NSObject

@property(nonatomic, readonly) DJIDrone* drone;

-(id) initWithDrone:(DJIDrone*)drone;

-(void) getVersionWithResult:(DJIGetVersionResultHandler)result;

@end
