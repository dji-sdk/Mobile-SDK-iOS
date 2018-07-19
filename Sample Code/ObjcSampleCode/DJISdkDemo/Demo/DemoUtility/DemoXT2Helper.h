//
//  DemoXT2Helper.h
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

@interface DemoXT2Helper : NSObject

+ (BOOL)isXT2Camera;
+ (nullable DJICamera *)connectedThermalCamera;
+ (nullable DJICamera *)connectedXT2VisionCamera;
+ (nullable DJICameraKey *)thermalCameraKeyWithParam:(nonnull NSString *)param;
+ (nullable DJICamera *)cameraAtComponentIndex:(NSInteger)componentIndex;

@end
