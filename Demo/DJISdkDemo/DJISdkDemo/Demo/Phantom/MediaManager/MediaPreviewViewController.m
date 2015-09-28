//
//  MediaPreviewViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-21.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "MediaPreviewViewController.h"

@interface MediaPreviewViewController ()

@end

@implementation MediaPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_media) {
        self.progressIndicator.center = self.view.center;
        [self.view addSubview:self.progressIndicator];
        [self.progressIndicator startAnimating];
        __block long long totalDownload = 0;
        long long fileSize = _media.fileSize;
        NSMutableData* mediaData = [[NSMutableData alloc] init];
        NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
        [_media fetchMediaData:^(NSData *data, BOOL *stop, NSError *error) {
            if (*stop) {
                if (error) {
                    NSLog(@"fetchMediaDataError:%@", error);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = [UIImage imageWithData:mediaData];
                        [self.progressIndicator stopAnimating];
                        [self.progressIndicator removeFromSuperview];
                    });
                }
            }
            else
            {
                if (data && data.length > 0) {
                    [mediaData appendData:data];
                    totalDownload += data.length;
                    int progress = (int)(totalDownload*100 / fileSize);
                    NSLog(@"Progress : %d", progress);
                    if (progress >= 100) {
                        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
                        NSLog(@"Fetch Media Data:%d", (int)((timeEnd - timeBegin)*1000));
                    }
                }
            }
        }];
    }
}

-(void) setMedia:(DJIMedia*)media
{
    _media = media;
}

@end
