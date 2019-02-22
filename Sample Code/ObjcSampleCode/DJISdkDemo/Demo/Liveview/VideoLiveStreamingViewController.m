//
//  VideoLiveStreamingViewController.h
//  DJISdkDemo
//
//  Copyright (c) 2018 DJI. All rights reserved.
//

#import "VideoLiveStreamingViewController.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import "VideoPreviewerSDKAdapter.h"
#import <DJIWidget/DJIRtmpMuxer.h>
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

@interface VideoLiveStreamingViewController () <DJIRtmpMuxerStateUpdateDelegate>

@property (weak, nonatomic) IBOutlet UILabel *liveStreamAudioGainLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveStreamButton;
@property (weak, nonatomic) IBOutlet UIButton *startLiveStreamButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableAudioSwitch;
@property (weak, nonatomic) IBOutlet UILabel *timeAndFPSLabel;

@property(nonatomic) UIView* videoPreviewView;

@property(nonatomic) VideoPreviewerSDKAdapter* previewerAdapter;
@property(nonatomic) DJIRtmpMuxer *rtmpMuxer;

@property(nonatomic) BOOL liveStreamIsOn;
@property(nonatomic) dispatch_source_t liveStreamWorkingTimer;
@property(nonatomic) NSTimeInterval liveStreamTime;
@property(nonatomic) NSString *serverURL;

@end

@implementation VideoLiveStreamingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setupVideoPreviewView];
	[self setupRtmpMuxer];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[[DJIVideoPreviewer instance] unSetView];
	[self.previewerAdapter stop];
	self.previewerAdapter = nil;
	
    [self.rtmpMuxer setEnabled:NO];
	self.rtmpMuxer.delegate = nil;
	[self stopLiveStream];
	self.rtmpMuxer = nil;
}

- (void)setupVideoPreviewView
{
	self.videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	self.videoPreviewView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:self.videoPreviewView];
	[self.view sendSubviewToBack:self.videoPreviewView];
	self.stopLiveStreamButton.enabled = NO;
	
	
	[DJIVideoPreviewer instance].type = DJIVideoPreviewerTypeAutoAdapt;
	[[DJIVideoPreviewer instance] start];
	[[DJIVideoPreviewer instance] reset];
	[[DJIVideoPreviewer instance] setView:self.videoPreviewView];
	[[DJIVideoPreviewer instance] setEnableHardwareDecode:YES];
	DJIVideoFeed *videoFeed = nil;
	videoFeed = [DJISDKManager videoFeeder].primaryVideoFeed;
	self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithVideoPreviewer:[DJIVideoPreviewer instance] andVideoFeed:videoFeed];
	[self.previewerAdapter start];
	[self.previewerAdapter setupFrameControlHandler];
}

- (void)setupRtmpMuxer
{
	self.rtmpMuxer = [DJIRtmpMuxer sharedInstance];
    self.rtmpMuxer.muteAudio = NO;
	[self.rtmpMuxer setupVideoPreviewer:[DJIVideoPreviewer instance]];
	self.rtmpMuxer.delegate = self;
}

- (IBAction)onStopLiveStreamingButtonClicked:(id)sender {
    WeakRef(target);
	[DemoAlertView showAlertViewWithMessage:@"Stop Live Streaming?" titles:@[@"Cancel", @"OK"] action:^(NSUInteger buttonIndex) {
        WeakReturn(target);
		if (buttonIndex == 1) {
			[target stopLiveStream];
		}
	}];
}

- (IBAction)onStartLiveStreamingButtonClicked:(id)sender {
	WeakRef(target);
	[DemoAlertView showAlertViewWithMessage:@"Please enter your Live Streaming Server URL" titles:@[@"Cancel", @"OK"] textFields:@[@"Live Streaming Server URL"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
		WeakReturn(target);
		if (buttonIndex) {
			NSString *serverURL = textFields[0].text;
			if (serverURL.length <= 0) {
				ShowResult(@"Please enter your server URL!");
			} else {
				target.serverURL = serverURL;
                [target startLiveStream];
			}
		}
	}];
}

- (IBAction)onAudioEnabledValueChanged:(id)sender {
	self.rtmpMuxer.muteAudio = self.enableAudioSwitch.isOn;
}

#pragma mark - Live Stream Control

-(void) createLiveVideoWithInfo:(NSDictionary*)info{
	if (self.serverURL.length <= 0) {
		return;
	}

    [self.rtmpMuxer setServerURL:self.serverURL];
    [self.rtmpMuxer setEnabled:YES];
    [self.rtmpMuxer setEnableAudio:YES];
    [self.rtmpMuxer setRetryCount:3];
    [self.rtmpMuxer start];
    [self startLiveStreamTimer];
}

-(void) countDownToStart{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self createLiveVideoWithInfo:nil];
	});
}

-(void) startLiveStream{
	
	self.liveStreamIsOn = YES;
	WeakRef(target);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		if(target.liveStreamIsOn){
			[target countDownToStart];
		}
	});
}

- (void)stopLiveStream {
	if (!self.liveStreamIsOn) {
		return;
	}
	
	self.liveStreamIsOn = NO;
	
	[self.rtmpMuxer stop];
	[self.rtmpMuxer setEnableAudio:NO];
	[self.rtmpMuxer setEnabled:NO];
	
	[self stopLiveTimer];
}

-(void) startLiveStreamTimer{
	if (self.liveStreamWorkingTimer) {
		return;
	}
	
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
	dispatch_source_set_event_handler(timer, ^{
		if (self.rtmpMuxer.status == DJIRtmpMuxerState_Streaming) {
			self.liveStreamTime += 1.0;
			NSString* timeAndFpsString = [NSString stringWithFormat:@"Time:%f  FPS:%f",self.liveStreamTime, self.rtmpMuxer.outputFps];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.timeAndFPSLabel.text = timeAndFpsString;
			});
		}
	});
	self.liveStreamWorkingTimer = timer;
	dispatch_resume(_liveStreamWorkingTimer);
	self.liveStreamTime = 0;
}

-(void) stopLiveTimer{
	if (self.liveStreamWorkingTimer) {
		dispatch_source_cancel(self.liveStreamWorkingTimer);
		self.liveStreamWorkingTimer = nil;
		self.liveStreamTime = 0;
	}
}

#pragma mark - State update

- (void)rtmpMuxer:(DJIRtmpMuxer *)rtmpMuxer didUpdateStreamState:(DJIRtmpMuxerState)status
{
	[self rtmpMuxerStatusChanged:status];
}

- (void)rtmpMuxer:(DJIRtmpMuxer *_Nonnull)rtmpMuxer didUpdateAudioGain:(float)gain {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSString* audioGainString = [NSString stringWithFormat:@"AudioGain: %f", gain];	dispatch_async(dispatch_get_main_queue(), ^{
			self.liveStreamAudioGainLabel.text = audioGainString;
		});
	});
}

- (void)rtmpMuxerStatusChanged:(DJIRtmpMuxerState)status
{
	NSString* statusString = @"";
	switch (status) {
		case DJIRtmpMuxerState_Init:
			statusString = @"Init";
			break;
		case DJIRtmpMuxerState_Connecting:
			statusString = @"Connecting";
			break;
		case DJIRtmpMuxerState_Broken:
			statusString = @"Broken";
			[self startLiveStream];
			break;
		case DJIRtmpMuxerState_Stoped:
			[self stopLiveStream];
			statusString = @"Stopped";
			break;
		case DJIRtmpMuxerState_Streaming:
			statusString = @"Streaming";
			break;
		case DJIRtmpMuxerState_prepareIFrame:
			statusString = @"prepareIFrame";
			break;
		default:
			break;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		self.statusLabel.text = [NSString stringWithFormat:@"Status: %@", statusString];
		if (self.rtmpMuxer.status == DJIRtmpMuxerState_Streaming) {
			self.stopLiveStreamButton.enabled = YES;
			self.startLiveStreamButton.enabled = NO;
		} else {
			self.stopLiveStreamButton.enabled = NO;
			self.startLiveStreamButton.enabled = YES;
		}
		if (self.rtmpMuxer.status == DJIRtmpMuxerState_Broken) {
			[self stopLiveStream];
		}
	});
}

@end

