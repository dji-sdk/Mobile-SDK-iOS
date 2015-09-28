//
//  InspireHotPointConfigView.h
//  DJISdkDemo
//
//  Created by Ares on 15/6/3.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@protocol HotPointConfigViewDelegate <NSObject, UITextFieldDelegate>

-(void) configViewWillDisappear;

@end

@interface HotPointConfigView : UIView

@property(nonatomic, weak) id<HotPointConfigViewDelegate> delegate;

@property(nonatomic, readonly) DJIHotPointEntryPoint entryPoint;
@property(nonatomic, readonly) DJIHotPointHeadingMode headingMode;
@property(nonatomic, readonly) float altitude;
@property(nonatomic, readonly) float radius;
@property(nonatomic, readonly) int speed;
@property(nonatomic, readonly) BOOL clockwise;

-(id) initWithNib;

-(void) setAltitude:(float)altitude;
@end
