//
//  DJIFoundation.h
//  DJISDK
//
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>

#ifdef __cplusplus
#define DJI_API_EXTERN       extern "C" __attribute__((visibility ("default")))
#else
#define DJI_API_EXTERN       extern __attribute__((visibility ("default")))
#endif

#define DJI_API_DEPRECATED __attribute__ ((__deprecated__))