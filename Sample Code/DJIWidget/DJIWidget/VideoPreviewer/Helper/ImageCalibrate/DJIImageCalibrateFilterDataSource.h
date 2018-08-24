//
//  DJIImageCalibrateFilterDataSource.h
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DJIImageCalibrateFilterDataSource_h
#define DJIImageCalibrateFilterDataSource_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DJIWidget/DJIStreamCommon.h>

@interface DJIImageCalibrateFilterDataSource : NSObject

-(void)loadDataForFrameSize:(CGSize)frameSize;

-(BOOL)checkDataReadyForFrameSize:(CGSize)frameSize;

//size:bytes
-(void)getVertexIndexDataForFrameSize:(CGSize)frameSize
                           andHandler:(void(^)(GLuint* data,NSUInteger size))handler;

//stride:bytes
-(void)getVertexDataForFrameSize:(CGSize)frameSize
                      andHandler:(void(^)(GLfloat* data,NSUInteger stride,NSUInteger totalIndex))handler;

//actual data index for lut index & fov state
-(NSUInteger)dataIndexForResolution:(CGSize)resolution
                           lutIndex:(NSUInteger)index
                        andFovState:(DJISEIInfoLiveViewFOVState)fovState;

//camera work mode:capture or record
@property (nonatomic,readonly) NSUInteger workMode;

+(instancetype)instanceWithWorkMode:(NSUInteger)workMode;

@end

#endif /* DJIImageCalibrateFilterDataSource_h */
