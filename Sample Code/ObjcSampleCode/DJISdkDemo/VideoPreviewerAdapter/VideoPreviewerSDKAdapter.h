//
//  VideoPreviewerSDKAdapter.h
//  VideoPreviewer
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import <DJIWidget/DJIVideoPreviewer.h>

@class DJIVideoPreviewer;

@interface VideoPreviewerSDKAdapter : NSObject <DJIVideoFeedSourceListener, DJIVideoFeedListener, DJIVideoPreviewerFrameControlDelegate>

+(instancetype)adapterWithDefaultSettings;

+(instancetype)adapterWithForLightbridge2; 

+(instancetype)adapterWithVideoPreviewer:(DJIVideoPreviewer *)videoPreviewer andVideoFeed:(DJIVideoFeed *)videoFeed;

@property (nonatomic, weak) DJIVideoPreviewer *videoPreviewer;

@property (nonatomic, weak) DJIVideoFeed *videoFeed;

-(void)start;

-(void)stop;

// For Mavic 2
-(void)setupFrameControlHandler;

@end
