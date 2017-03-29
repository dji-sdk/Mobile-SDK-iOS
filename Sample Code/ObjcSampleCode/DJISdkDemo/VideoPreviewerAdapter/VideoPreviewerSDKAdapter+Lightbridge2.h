//
//  VideoPreviewerSDKAdapter.m
//  VideoPreviewer
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "VideoPreviewerSDKAdapter.h"

@interface VideoPreviewerSDKAdapter ()

@property (nonatomic) NSNumber *isEXTPortEnabled; // BOOL
@property (nonatomic) NSNumber *LBEXTPercent; // float
@property (nonatomic) NSNumber *HDMIAVPercent; // float

@end

@interface VideoPreviewerSDKAdapter (Lightbridge2)

-(void)startLightbridgeListen;
-(void)stopLightbridgeListen;

@end
