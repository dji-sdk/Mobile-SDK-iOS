//
//  DJICameraRemotePlayerView.h
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DJICameraRemotePlayerView : UIView

-(id) initWithPlayerLayer:(AVPlayerLayer*)layer;

-(void) reDraw;
@end
