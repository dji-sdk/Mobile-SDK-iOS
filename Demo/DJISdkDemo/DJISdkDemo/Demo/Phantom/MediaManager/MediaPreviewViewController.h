//
//  MediaPreviewViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-21.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface MediaPreviewViewController : UIViewController
{
    DJIMedia* _media;
}

@property(nonatomic, retain) IBOutlet UIImageView* imageView;
@property(nonatomic, retain) UIActivityIndicatorView* progressIndicator;

-(void) setMedia:(DJIMedia*)media;

@end
