//
//  VisualStickView.h
//  SampleGame
//
//  Copyright (c) 2013 Myst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCVirtualStickView : UIView
{
    IBOutlet UIImageView *stickViewBase;
    IBOutlet UIImageView *stickView;
    
    UIImage *imgStickNormal;
    UIImage *imgStickHold;
    
    CGPoint mCenter;
    
    NSTimer* mUpdateTimer;
    CGPoint mTouchPoint;
}

@end
