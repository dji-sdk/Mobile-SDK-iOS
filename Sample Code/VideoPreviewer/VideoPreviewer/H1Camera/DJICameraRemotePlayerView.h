//
//  DJICameraRemotePlayerView.h
//  Phantom3
//
//  Created by ai.chuyue on 2016/11/21.
//  Copyright © 2016年 DJIDevelopers.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DJICameraRemotePlayerView : UIView

-(id) initWithPlayerLayer:(AVPlayerLayer*)layer;

-(void) reDraw;
@end
