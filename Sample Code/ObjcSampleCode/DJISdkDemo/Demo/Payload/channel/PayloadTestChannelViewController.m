//
//  PayloadTestChannelViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "PayloadTestChannelViewController.h"
#import "VideoPreviewerSDKAdapter.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJISDK/DJISDK.h>
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"

@interface PayloadTestChannelViewController ()
<DJICameraDelegate, DJIPayloadDelegate>

@property(nonatomic, assign) BOOL needToSetMode;
@property(nonatomic) VideoPreviewerSDKAdapter *previewerAdapter;
@property (weak, nonatomic) IBOutlet UIView *fpvView;
@property (weak, nonatomic) IBOutlet UITextView *cmdData;

@end

@implementation PayloadTestChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        camera.delegate = self;
    }
    
    self.needToSetMode = YES;
    
    [[DJIVideoPreviewer instance] start];
    self.previewerAdapter = [VideoPreviewerSDKAdapter adapterWithDefaultSettings];
    [self.previewerAdapter start];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[DemoComponentHelper fetchPayload] setDelegate:self];
    
    [[DJIVideoPreviewer instance] setView:self.fpvView];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Call unSetView during exiting to release the memory.
    [[DJIVideoPreviewer instance] unSetView];
    
    if (self.previewerAdapter) {
        [self.previewerAdapter stop];
        self.previewerAdapter = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DJICameraDelegate

-(void)camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState
{
    if (systemState.mode == DJICameraModePlayback ||
        systemState.mode == DJICameraModeMediaDownload) {
        if (self.needToSetMode) {
            self.needToSetMode = NO;
            WeakRef(obj);
            [camera setMode:DJICameraModeShootPhoto withCompletion:^(NSError * _Nullable error) {
                if (error) {
                    WeakReturn(obj);
                    obj.needToSetMode = YES;
                }
            }];
        }
    }
}

#pragma mark - DJIPayloadDelegate

- (void)payload:(DJIPayload *)payload didReceiveStreamData:(NSData *)data {
    NSString *content = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    
    if (!content) {
        return;
    }
    
    self.cmdData.text = content;
}

-(void)payload:(DJIPayload *)payload didReceiveVideoData:(NSData *)data {
    [self.previewerAdapter.videoPreviewer push:(uint8_t *)[data bytes] length:(int)data.length];
}

@end
