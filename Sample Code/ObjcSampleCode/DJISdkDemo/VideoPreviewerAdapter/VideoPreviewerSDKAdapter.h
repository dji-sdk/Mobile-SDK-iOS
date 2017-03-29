//
//  VideoPreviewerSDKAdapter.h
//  VideoPreviewer
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

@class VideoPreviewer;

@interface VideoPreviewerSDKAdapter : NSObject <DJIVideoFeedSourceListener, DJIVideoFeedListener>

+(instancetype)adapterWithDefaultSettings;

+(instancetype)adapterWithForLightbridge2; 

+(instancetype)adapterWithVideoPreviewer:(VideoPreviewer *)videoPreviewer andVideoFeed:(DJIVideoFeed *)videoFeed;

@property (nonatomic, weak) VideoPreviewer *videoPreviewer;

@property (nonatomic, weak) DJIVideoFeed *videoFeed;

-(void)start;

-(void)stop;

@end
