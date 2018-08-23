//
//  DJIGimbal+CapabilityCheck.h
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <DJISDK/DJISDK.h>

@interface DJIGimbal (CapabilityCheck)

-(BOOL) isFeatureSupported:(NSString *)key;
-(NSNumber *) getParamMin:(NSString *)key;
-(NSNumber *) getParamMax:(NSString *)key;

@end
