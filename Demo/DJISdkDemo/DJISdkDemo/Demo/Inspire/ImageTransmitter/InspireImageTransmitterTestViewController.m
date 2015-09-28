//
//  InspireOFDMTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/4/9.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "InspireImageTransmitterTestViewController.h"

#define OFDM_CHANNEL_VIEW_TAG_BEGIN (1000)
#define OFDM_CHANNEL_VIEW_TAG_END   (1007)

#define OFDM_USEABLE_CHANNEL_BEGIN  (13)
#define OFDM_USEABLE_CHANNEL_END    (20)

@interface InspireImageTransmitterTestViewController ()
- (IBAction)onChannelSelectionChanged:(id)sender;
- (IBAction)onBandwidthSelectionChanged:(id)sender;
- (IBAction)onDoubleOutputSelectionChanged:(id)sender;

@end

@implementation InspireImageTransmitterTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.connectedDrone) {
        mDrone = self.connectedDrone;
    }
    else
    {
        mDrone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    }
    mDrone.delegate = self;
    mImageTransmitter = mDrone.imageTransmitter;
    mImageTransmitter.delegate = self;
    
    mChannels = [[NSMutableArray alloc] init];
    for (int viewTag = OFDM_CHANNEL_VIEW_TAG_BEGIN; viewTag <= OFDM_CHANNEL_VIEW_TAG_END ; viewTag++) {
        UIProgressView* progress = (UIProgressView*)[self.view viewWithTag:viewTag];
        [progress setProgress:0];
        [mChannels addObject:progress];
    }
    
    self.rcSignalPercentLabel.layer.cornerRadius = 4.0;
    self.rcSignalPercentLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.rcSignalPercentLabel.layer.borderWidth = 1.2;
    self.rcSignalPercentLabel.layer.masksToBounds = YES;
    
    self.videoSignalPercentLabel.layer.cornerRadius = 4.0;
    self.videoSignalPercentLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.videoSignalPercentLabel.layer.borderWidth = 1.2;
    self.videoSignalPercentLabel.layer.masksToBounds = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [mDrone connectToDrone];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [mImageTransmitter stopChannelPowerUpdatesWithResult:nil];
    [mDrone disconnectToDrone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshAll
{
    WeakRef(obj);
    
    [mImageTransmitter startChannelPowerUpdatesWithResult:nil];
    
    [mImageTransmitter getChannelWithResult:^(uint8_t channel, BOOL isAuto, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            UISegmentedControl* control = (UISegmentedControl*)([obj.view viewWithTag:100]);
            if (control) {
                if (isAuto) {
                    [control setSelectedSegmentIndex:(control.numberOfSegments - 1)];
                }
                else
                {
                    int index = channel - OFDM_USEABLE_CHANNEL_BEGIN;
                    if (index >= 0 && index < control.numberOfSegments) {
                        [control setSelectedSegmentIndex:index];
                    }
                }
            }
        }
    }];
    
    [mImageTransmitter getBandwidthWithResult:^(DJIImageTransmitterBandwidth bandwidth, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            UISegmentedControl* control = (UISegmentedControl*)([obj.view viewWithTag:200]);
            if (control) {
                int index = (int)bandwidth;
                if (index > 4 || index < 0) {
                    NSLog(@"BandWidth Error:%d", index);
                }
                else
                {
                    [control setSelectedSegmentIndex:(int)bandwidth];
                }
                
            }
        }
    }];

    [mImageTransmitter getDoubleOutputState:^(BOOL isDouble, DJIError *error) {
        if (error.errorCode == ERR_Succeeded) {
            WeakReturn(obj);
            UISwitch* control = (UISwitch*)([obj.view viewWithTag:300]);
            if (control) {
                [control setOn:isDouble];
            }
        }
    }];
}

- (IBAction)onChannelSelectionChanged:(UISegmentedControl*)sender
{
    uint8_t channel = sender.selectedSegmentIndex + OFDM_USEABLE_CHANNEL_BEGIN;
    if (channel > OFDM_USEABLE_CHANNEL_END) {
        [mImageTransmitter setChannelAutoSelectWithResult:^(DJIError *error) {
            ShowResult(@"Set Channel Auto Select Result:%@", error.errorDescription);
        }];
    }
    else
    {
        [mImageTransmitter setChannel:channel withResult:^(DJIError *error) {
            ShowResult(@"Set Channel Result:%@", error.errorDescription);
        }];
    }
}

- (IBAction)onBandwidthSelectionChanged:(UISegmentedControl*)sender
{
    DJIImageTransmitterBandwidth bandwidth = (DJIImageTransmitterBandwidth)(sender.selectedSegmentIndex);
    [mImageTransmitter setBandWidth:bandwidth withResult:^(DJIError *error) {
        ShowResult(@"Set Bandwidth Result:%@", error.errorDescription);
    }];
}

- (IBAction)onDoubleOutputSelectionChanged:(UISwitch*)sender
{
    [mImageTransmitter setDoubleOutput:sender.on withResult:^(DJIError *error) {
        ShowResult(@"Set Double Output Result:%@", error.errorDescription);
    }];
}

#pragma mark - OFDMDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        [self refreshAll];
    }
}

-(void) imageTransmitter:(DJIImageTransmitter*)transmitter didUpdateRadioSignalQuality:(DJIImageTransmitterRadioSignalQuality)quality
{
    if (quality.mUpLink) {
        self.rcSignalPercentLabel.text = [NSString stringWithFormat:@"%d%%", quality.mPercent];
    }
    else
    {
        self.videoSignalPercentLabel.text = [NSString stringWithFormat:@"%d%%",quality.mPercent];
    }
}

-(void) imageTransmitter:(DJIImageTransmitter*)transmitter didUpdateChannelPower:(DJIImageTransmitterChannelPower)power
{
    for (int ch = OFDM_USEABLE_CHANNEL_BEGIN; ch <= OFDM_USEABLE_CHANNEL_END; ch++) {
        int index = ch - OFDM_USEABLE_CHANNEL_BEGIN;
        UIProgressView* progressView = [mChannels objectAtIndex:index];
        float progress = (power.mRssi[ch - 1] - IMAGE_TRANSMITTER_RSSI_MIN) * 1.0/(IMAGE_TRANSMITTER_RSSI_MAX - IMAGE_TRANSMITTER_RSSI_MIN);
        [progressView setProgress:progress animated:YES];
    }
}
@end
