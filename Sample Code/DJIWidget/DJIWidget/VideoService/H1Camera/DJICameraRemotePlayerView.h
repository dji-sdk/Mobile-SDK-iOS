//
//  DJICameraRemotePlayerView.h
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DJICameraRemotePlayerView : UIView

-(id) initWithPlayerLayer:(AVPlayerLayer*)layer;

-(void) reDraw;
@end
