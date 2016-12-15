//
//  VideoPreviewerSDKAdapter.h
//  VideoPreviewer
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoPreviewer;

@interface VideoPreviewerSDKAdapter : NSObject

+(instancetype)adapterWithVideoPreviewer:(VideoPreviewer *)videoPreviewer;

@property (nonatomic, weak) VideoPreviewer *videoPreviewer;

@property (nonatomic) BOOL isSecondaryLiveStream; // Only useful for Inspire 2

-(void)start;

-(void)stop;


@end
