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

-(void)start;

-(void)stop;


@end
