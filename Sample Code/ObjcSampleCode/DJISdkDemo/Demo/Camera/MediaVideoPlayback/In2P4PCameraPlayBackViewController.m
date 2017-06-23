//
//  In2P4PCameraPlayBackViewController.m
//  DJISdkDemo
//
//  Copyright © 2017 DJI. All rights reserved.
//

#import "In2P4PCameraPlayBackViewController.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>


@interface In2P4PCameraPlaybackViewCell : UITableViewCell
@property (nonatomic) DJIMediaFile *media;
@end

@implementation In2P4PCameraPlaybackViewCell
@end

@interface In2P4PCameraPlayBackViewController ()<DJIMediaManagerDelegate, UITableViewDelegate, UITableViewDataSource>
//DJICameraDelegate
//UI
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *getFilesButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalTime;

@property (weak, nonatomic) IBOutlet UIView *downloadListView;
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UIView *viewSlider;

@property (nonatomic, strong) UITableView *mediaListTable;
@property (nonatomic, strong) UISlider *processSlider;

//DJIRemoteGalleryPlayerController.m
@property (nonatomic, strong) DJIMediaManager* manager;

//data
@property (nonatomic, strong) NSArray *mediaList;
@property (nonatomic, strong) DJIMediaFile* selectedMedia;
@property (nonatomic, weak) DJIMediaManager *mediaManager;

@property (nonatomic, strong) DJIRTPlayerRenderView *renderView;

// User is interacting with the progress bar.
@property (nonatomic, assign) BOOL isInteractive;

@property (nonatomic) DJIMediaVideoPlaybackState *playbackState;

@end

@implementation In2P4PCameraPlayBackViewController

-(DJIMediaManager *)manager {
    return [DemoComponentHelper fetchCamera].mediaManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initEvent];
}

-(void)dealloc
{
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera == nil) return;

    [camera setMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Set camera mode failed: %@", error.description);
        }
    }]; 
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews{
    
    DJICamera *camera = [DemoComponentHelper fetchCamera];
    self.mediaManager = camera.mediaManager;
    self.mediaManager.delegate = self;
    _renderView = [[DJIRTPlayerRenderView alloc] initWithDecoderType:LiveStreamDecodeType_VTHardware
                                                         encoderType:H264EncoderType_H1_Inspire2];
    _renderView.frame = _preView.bounds;
    [_preView addSubview:_renderView];
    
    [self initTableView];
    [self loadMediaList];
    [self initSliderView];
}

- (void)initTableView{
    UIButton *buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 20)];
    buttonBack.backgroundColor = [UIColor redColor];
    [buttonBack setTitle:@"Back" forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(backToPreVC) forControlEvents:UIControlEventTouchUpInside];
    
    self.mediaListTable = [[UITableView alloc] initWithFrame:self.downloadListView.bounds];
    self.mediaListTable.backgroundColor = [UIColor grayColor];
    [self.downloadListView addSubview:self.mediaListTable];
    self.mediaListTable.delegate = self;
    self.mediaListTable.dataSource = self;
    
    [self.view addSubview:buttonBack];
    [buttonBack bringSubviewToFront:self.view];
}

- (void)initSliderView{
    _processSlider = [[UISlider alloc] initWithFrame:self.viewSlider.bounds];
    _processSlider.backgroundColor = [UIColor clearColor];
    _processSlider.userInteractionEnabled = YES;
    [self.viewSlider addSubview:_processSlider];
    
    _processSlider.value = 0.0;
    _processSlider.minimumValue = 0;
    _processSlider.maximumTrackTintColor = [UIColor whiteColor];
    _processSlider.minimumTrackTintColor = [UIColor whiteColor];
    
    [_processSlider addTarget:self action:@selector(beginSlider:) forControlEvents:UIControlEventTouchDown];
    [_processSlider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
    [_processSlider addTarget:self action:@selector(endSlider:) forControlEvents:UIControlEventTouchUpInside];
    [_processSlider addTarget:self action:@selector(endSlider:) forControlEvents:UIControlEventTouchUpOutside];
    [_processSlider addTarget:self action:@selector(endSlider:) forControlEvents:UIControlEventTouchCancel];
}

- (void)backToPreVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMediaList {
    WeakRef(target);
    [self.mediaManager refreshFileListWithCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"Fetch media failed: %@", error.localizedDescription);
        }
        else {
            target.mediaList = [target.mediaManager fileListSnapshot];
            [target.mediaListTable reloadData];
        }
    }];
}

#pragma mark- Media Event
- (void)initEvent{
    [self.playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.getFilesButton addTarget:self action:@selector(getFilesAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(stopPlayAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (BOOL)isNeedShowTipSelectFile{
    if(!self.selectedMedia){
        ShowResult(@"You must select a file!");
        return YES;
    }
    return NO;
}
- (void)playAction:(id) sender{
    if([self isNeedShowTipSelectFile]){
        return;
    }

    [self.manager playVideo:self.selectedMedia withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Play failed: %@", error.description);
        }
        NSLog(@"Play failed: %@", error.description);
    }];
}

- (void)pauseAction:(id) sender{
    if([self isNeedShowTipSelectFile]){
        return;
    }
    if (self.playbackState.playbackStatus == DJIMediaVideoPlaybackStatusPaused) {
        [self.manager resumeWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Resume failed: %@", error.description);
            }
        }];
    }
    else {
        [self.manager pauseWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Pause failed: %@", error.description);
            }
        }];
    }
}
- (void)stopPlayAction:(id) sender{
    if([self isNeedShowTipSelectFile]){
        return;
    }
    [self.manager stopWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Stop failed: %@", error.description);
        }
    }];
}
- (void)getFilesAction:(id) sender{
    [self loadMediaList];
}


#pragma mark- Touch Event
-(void) beginSlider:(id)sender{
    if([self isNeedShowTipSelectFile]){
        return;
    }
    
    self.isInteractive = YES;
}

-(void) changeSlider:(id)sender
{
    if(self.isInteractive){
        [self.manager moveToPosition:self.processSlider.value withCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"MoveToPosition Error: %@", error.description);
            }
        }];
    }
}

-(void) endSlider:(id)sender{
    self.isInteractive = NO;
    
    //seek
    [self.manager moveToPosition:self.processSlider.value withCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"MoveToPosition Error: %@", error.description);
        }
    }];
}

#pragma mark- UITableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* s_Identifier1 = @"s_Identifier1";
    In2P4PCameraPlaybackViewCell *cell = [self.mediaListTable dequeueReusableCellWithIdentifier:s_Identifier1];
    if (cell == nil) {
        cell = [[In2P4PCameraPlaybackViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:s_Identifier1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    cell.media = self.mediaList[indexPath.row];
    cell.textLabel.text = cell.media.fileName;
    
    if (cell.media.mediaType == DJIMediaTypeMOV ||
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
    self.selectedMedia = self.mediaList[indexPath.row];
}

#pragma mark- 增加观察者
-(void) syncWithSliderUI{
    //更新进度条时间
    if (self.isInteractive) {
        return;
    }
    
    self.processSlider.value = self.playbackState.playingPosition;
    self.processSlider.maximumValue = self.selectedMedia.durationInSeconds;
    
    _labelCurrentTime.text = [self stringFromDuration:self.playbackState.playingPosition];
    _labelTotalTime.text = [self stringFromDuration:self.selectedMedia.durationInSeconds];
}

-(void) syncWithButtonUI {
    if (self.playbackState.playbackStatus == DJIMediaVideoPlaybackStatusPaused) {
        [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
    }
    else {
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

-(NSString*) stringFromDuration:(NSTimeInterval)duration{
    NSUInteger min = (NSUInteger)duration/60;
    NSUInteger sec = (NSUInteger)duration%60;
    
    return [NSString stringWithFormat:@"%tu:%02tu",
            min, sec];
}

-(void)manager:(DJIMediaManager *)manager didUpdateVideoPlaybackData:(uint8_t *)data length:(size_t)length forRendering:(BOOL)forRendering {
    [_renderView decodeH264CompleteFrameData:data
                                      length:length
                                  decodeOnly:!forRendering];
}

-(void)manager:(DJIMediaManager *)manager didUpdateVideoPlaybackState:(DJIMediaVideoPlaybackState *)state {
    NSLog(@"Playing file: %@", state.playingMedia.fileName);
    NSLog(@"Current position: %lf", state.playingPosition);
    NSLog(@"Status: %tu", state.playbackStatus);
    self.playbackState = state;
    [self syncWithSliderUI];
    [self syncWithButtonUI];
}

@end
