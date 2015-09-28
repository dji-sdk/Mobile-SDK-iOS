//
//  VisualStickView.m
//  SampleGame
//
//  Created by Zhang Xiang on 13-4-26.
//  Copyright (c) 2013年 Myst. All rights reserved.
//

#import "JoyStickView.h"

#define STICK_CENTER_TARGET_POS_LEN 20.0f

@implementation JoyStickView

-(void) initStick
{
    imgStickNormal = [UIImage imageNamed:@"stick_normal.png"];
    imgStickHold = [UIImage imageNamed:@"stick_hold.png"];
//    stickView.image = imgStickNormal;
    mCenter.x = 64;
    mCenter.y = 64;
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStick];
    }
    return self;
}

-(void) onPanGesture:(id)sender
{
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
        // Initialization code
        [self initStick];
    }
	
    return self;
}

- (void)dealloc {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)notifyDir:(CGPoint)dir
{
    NSValue *vdir = [NSValue valueWithCGPoint:dir];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              vdir, @"dir", nil];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"StickChanged" object:self userInfo:userInfo];
}

- (void)stickMoveTo:(CGPoint)deltaToCenter
{
    CGRect fr = stickView.frame;
    fr.origin.x = deltaToCenter.x;
    fr.origin.y = deltaToCenter.y;
    stickView.frame = fr;
}

- (void)touchEvent:(NSSet *)touches
{
    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    CGPoint touchPoint = [touch locationInView:view];
    CGPoint dtarget, dir;
    dir.x = touchPoint.x - mCenter.x;
    dir.y = touchPoint.y - mCenter.y;
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);

    if(len < 10.0 && len > -10.0)
    {
        // center pos
        dtarget.x = 0.0;
        dtarget.y = 0.0;
        dir.x = 0;
        dir.y = 0;
    }
    else
    {
        double len_inv = (1.0 / len);
        dir.x *= len_inv;
        dir.y *= len_inv;
        dtarget.x = dir.x * STICK_CENTER_TARGET_POS_LEN;
        dtarget.y = dir.y * STICK_CENTER_TARGET_POS_LEN;
    }
    [self stickMoveTo:dtarget];
    
    [self notifyDir:dir];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickHold;
    
    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    mTouchPoint= [touch locationInView:view];
    [self startUpdateTimer];
//    [self touchEvent:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([touches count] != 1)
        return ;
    
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    if(view != self)
        return ;
    
    mTouchPoint= [touch locationInView:view];
    
//    [self touchEvent:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickNormal;
    CGPoint dtarget, dir;
    dir.x = dtarget.x = 0.0;
    dir.y = dtarget.y = 0.0;
    [self stickMoveTo:dtarget];
    
    [self notifyDir:dir];
    [self stopUpdateTimer];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    stickView.image = imgStickNormal;
    CGPoint dtarget, dir;
    dir.x = dtarget.x = 0.0;
    dir.y = dtarget.y = 0.0;
    [self stickMoveTo:dtarget];
    
    [self notifyDir:dir];
    [self stopUpdateTimer];
}

-(void) onUpdateTimerTicked:(id)sender
{
    CGPoint touchPoint = mTouchPoint;
    CGPoint dtarget, dir;
    dir.x = touchPoint.x - mCenter.x;
    dir.y = touchPoint.y - mCenter.y;
    double len = sqrt(dir.x * dir.x + dir.y * dir.y);
    
    if (len > STICK_CENTER_TARGET_POS_LEN) {
        double len_inv = (1.0 / len);
        dir.x *= len_inv;
        dir.y *= len_inv;
        dtarget.x = dir.x * STICK_CENTER_TARGET_POS_LEN;
        dtarget.y = dir.y * STICK_CENTER_TARGET_POS_LEN;
    }
    else
    {
        dtarget.x = dir.x;
        dtarget.y = dir.y;
    }
    dir.x= dtarget.x / STICK_CENTER_TARGET_POS_LEN;
    dir.y =dtarget.y / STICK_CENTER_TARGET_POS_LEN;
    [self stickMoveTo:dtarget];
    
    [self notifyDir:dir];
}

-(void) startUpdateTimer
{
    if (mUpdateTimer == nil) {
        mUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onUpdateTimerTicked:) userInfo:nil repeats:YES];
        [mUpdateTimer fire];
    }
}

-(void) stopUpdateTimer
{
    if (mUpdateTimer) {
        [mUpdateTimer invalidate];
        mUpdateTimer = nil;
    }
}
@end
