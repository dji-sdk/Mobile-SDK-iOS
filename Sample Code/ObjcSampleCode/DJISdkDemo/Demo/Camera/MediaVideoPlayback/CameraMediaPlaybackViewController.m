//
//  CameraMediaPlaybackViewController.m
//  DJISdkDemo
//
//  Copyright © 2016 DJI. All rights reserved.
//

#import "CameraMediaPlaybackViewController.h"
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
#import <VideoPreviewer/VideoPreviewer.h>

/**
 *  This file demonstrates how to use the video playback in media manager. It
 *  includes:
 *  1. How to show the video feed on the view. Video feed of the playing video
 *     is delivered through [camera:didReceiveVideoData:]. The video feed is
 *     is displayed using VideoPreviewer.
 *  2. How to set delegate to the media manager. It is important to check
 *     current playback state.
 *  3. How to select the video to play.
 *  4. How to pause or resume the playing video.
 *  The basic workflow is as follows:
 *  1. Change the current camera mode to DJICameraModeMediaDownload.
 *  2. Load the list of media files.
 *  3. Start playing a video file using media manager.
 *  4. Get the state through a delegate method.
 *  5. Control the playing using media manager.
 */
@interface MediaPlaybackViewCell : UITableViewCell

@property (nonatomic) DJIMedia *media;

@end

@implementation MediaPlaybackViewCell

@end

@interface CameraMediaPlaybackViewController ()
<DJIMediaManagerDelegate,
DJICameraDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic) NSArray *mediaList;
@property (nonatomic) DJIMedia *selectedMedia;
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (nonatomic, weak) DJIMediaManager *mediaManager;
@property (weak, nonatomic) IBOutlet UITableView *mediaListTable;
@property (nonatomic) DemoScrollView *statusView;
@property (weak, nonatomic) IBOutlet UITextField *seekText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation CameraMediaPlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mediaListTable.delegate = self;
    self.mediaListTable.dataSource = self;

    self.statusView = [DemoScrollView viewWithViewController:self];
    [self.statusView setHidden:YES];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchMediaList];
    [self setupVideoPreviewView];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cleanupVideoPreviewView];
}

- (void)fetchMediaList{
    DJICamera *camera = [DemoComponentHelper fetchCamera];
    camera.delegate = self;
    self.mediaManager = camera.mediaManager;
    self.mediaManager.delegate = self;
    
    if (![self.mediaManager isVideoPlaybackSupported]) {
        ShowResult(@"Video Playback is not supported by the product. ");
        return;
    }
    
    [self loadMediaList];
}

- (void)setupVideoPreviewView
{
    self.videoPreviewView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoPreviewView];
    [self.view sendSubviewToBack:self.videoPreviewView];

    [VideoPreviewer instance].type = VideoPreviewerTypeAutoAdapt;
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] reset];
    [[VideoPreviewer instance] setView:self.videoPreviewView];

#if !TARGET_IPHONE_SIMULATOR
    [VideoPreviewer instance].enableHardwareDecode = YES;
#endif

    [VideoPreviewer instance].encoderType = H264EncoderType_unknown;
}

-(void)cleanupVideoPreviewView
{
    if (self.videoPreviewView != nil) {
        [self.videoPreviewView removeFromSuperview];
        self.videoPreviewView = nil;
    }

    [[VideoPreviewer instance] unSetView];
}

-(void) loadMediaList {
    WeakRef(target);
    
    [self showActivityIndicator:YES];
    DJICamera *camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        [camera setCameraMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"SetCameraMode Failed: %@", error.description);
            }
            else {
                WeakReturn(target); 
                [self.mediaManager fetchMediaListWithCompletion:
                 ^(NSArray<DJIMedia *> * _Nullable mediaList, NSError * _Nullable error) {
                     WeakReturn(target);
                     
                     [target showActivityIndicator:NO];
                     
                     if (error) {
                         ShowResult(@"Fetch media failed: %@", error.localizedDescription);
                     }
                     else {
                         target.mediaList = mediaList;
                         [target.mediaListTable reloadData];
                     }
                 }];
            }
        }];
    }
}

- (void)showActivityIndicator:(BOOL)isShow
{
    if (isShow) {
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
    }else
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
    }

}

- (IBAction)onStatusClicked:(id)sender {
    [self.statusView setHidden:NO];
    [self.statusView show];
}

- (IBAction)onPlayClicked:(id)sender {
    [self.mediaManager resumeWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"FAILED: %@", error.description);
        }
        else {
            NSLog(@"Success. ");
        }

    }];
}

- (IBAction)onPauseClicked:(id)sender {
    [self.mediaManager pauseWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"FAILED: %@", error.description);
        }
        else {
            NSLog(@"Success. ");
        }

    }];
}

- (IBAction)onStopClicked:(id)sender {
    [self.mediaManager stopWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"FAILED: %@", error.description);
        }
        else {
            NSLog(@"Success. ");
        }

    }];
}

- (IBAction)onSeekClicked:(id)sender {
    NSUInteger second = 0;
    if (self.seekText.text.length) {
        second = [self.seekText.text floatValue];
    }

    [self.mediaManager moveToPosition:second withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"FAILED: %@", error.description);
        }
        else {
            NSLog(@"Success. ");
        }

    }];
}

- (IBAction)onBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* s_Identifier1 = @"s_Identifier1";
    MediaPlaybackViewCell *cell = [self.mediaListTable dequeueReusableCellWithIdentifier:s_Identifier1];
    if (cell == nil) {
        cell = [[MediaPlaybackViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:s_Identifier1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.media = self.mediaList[indexPath.row];
    cell.textLabel.text = cell.media.fileName;

    if (cell.media.mediaType == DJIMediaTypeM4V ||
        cell.media.mediaType == DJIMediaTypeMOV ||
        cell.media.mediaType == DJIMediaTypeMP4) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeakRef(target);
    self.selectedMedia = self.mediaList[indexPath.row];
    [self.mediaManager playVideo:self.selectedMedia withCompletion:^(NSError * _Nullable error) {
        
        WeakReturn(target);
        if (error) {
            [DemoAlertView showAlertViewWithMessage:[NSString stringWithFormat:@"%@", error.description] titles:@[@"OK"] action:nil presentedViewController:target];
        }
        else {
            NSLog(@"Play Video Success.");
        }
    }];
}

- (void)manager:(DJIMediaManager *)manager didUpdateVideoPlaybackState:(DJIMediaVideoPlaybackState *)state {
    NSMutableString *stateStr = [NSMutableString string];
    if (state.playingMedia == nil) {
        [stateStr appendString:@"No media\n"];
    }
    else {
        [stateStr appendFormat:@"media: %@\n", state.playingMedia.fileName];
        [stateStr appendFormat:@"Total: %f\n", state.playingMedia.durationInSeconds];
        [stateStr appendFormat:@"Orientation: %@\n", [self orientationToString:state.playingMedia.videoOrientation]];

        if (state.playingMedia.videoOrientation == DJICameraOrientationLandscape) {
            [VideoPreviewer instance].rotation = VideoStreamRotationDefault;
        }
        else if (state.playingMedia.videoOrientation == DJICameraOrientationPortrait) {
            [VideoPreviewer instance].rotation = VideoStreamRotationCW90;
        }
    }
    [stateStr appendFormat:@"Status: %@\n", [self statusToString:state.playbackStatus]];
    [stateStr appendFormat:@"Position: %f\n", state.playingPosition];

    [self.statusView writeStatus:stateStr];
}

-(NSString *)statusToString:(DJIMediaVideoPlaybackStatus)status {
    switch (status) {
        case DJIMediaVideoPlaybackStatusPaused:
            return @"Paused";
        case DJIMediaVideoPlaybackStatusPlaying:
            return @"Playing";
        case DJIMediaVideoPlaybackStatusStopped:
            return @"Stopped";
        default:
            break;
    }
    return nil;
}

-(NSString *)orientationToString:(DJICameraOrientation)orientation {
    switch (orientation) {
        case DJICameraOrientationLandscape:
            return @"Landscape";
        case DJICameraOrientationPortrait:
            return @"Portrait";
        default:
            break;
    }
    return nil;
}

-(void)camera:(DJICamera *)camera didReceiveVideoData:(uint8_t *)videoBuffer length:(size_t)size {
    [[VideoPreviewer instance] push:videoBuffer length:(int)size];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft; 
}

@end
