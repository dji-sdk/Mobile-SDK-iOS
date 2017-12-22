//
//  DJICameraRemotePlayerView.m
//

#import "DJICameraRemotePlayerView.h"

@interface DJICameraRemotePlayerView ()
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@end

@implementation DJICameraRemotePlayerView

-(id) initWithPlayerLayer:(AVPlayerLayer *)layer{
    if (self = [super initWithFrame:layer.frame]) {
        self.playerLayer = layer;
        [self.layer addSublayer:layer];
    }
    return self;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    
    _playerLayer.frame = self.layer.bounds;
}

-(void) reDraw{
    //do nothing
}

@end
