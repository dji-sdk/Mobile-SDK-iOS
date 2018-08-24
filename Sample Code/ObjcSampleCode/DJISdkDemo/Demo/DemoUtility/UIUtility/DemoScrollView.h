//
//  DemoScrollView.h
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoScrollView : UIView

@property(nonatomic, assign) float fontSize;

@property(nonatomic, strong) NSString* title;

-(void) writeStatus:(NSString*)status;

-(void) show;

-(void)setDefaultSize; 

+(instancetype)viewWithViewController:(UIViewController *)viewController;

@end
