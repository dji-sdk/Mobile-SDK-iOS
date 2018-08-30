//
//  DJIPixelCache.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//
#ifndef DJIPixelCache_h
#define DJIPixelCache_h

#import <DJIWidget/DJIStreamCommon.h>

@interface DJIPixelCache : NSObject

-(instancetype)initWithFrameWidth:(NSUInteger)width
                           height:(NSUInteger)height
                     andFrameType:(OSType)type;

-(BOOL)checkFitsFrameWidth:(NSUInteger)width
                    height:(NSUInteger)height
              andFrameType:(OSType)type;

-(CVPixelBufferRef)pixelBuffer;

@end

#endif /* DJIPixelCache_h */
