//
//  SpeakerViewController.m
//  DJISdkDemo
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import "SpeakerViewController.h"
#import "RecordingHandler.h"
#import "DemoComponentHelper.h"
#import "DemoUtilityMacro.h"
#import "DemoUtility.h"
#import <AVFoundation/AVFoundation.h>
#import "SpeakerAudioPlaylistTableViewCell.h"

NSString *const SpeakerPlayListCellID = @"SpeakerPlayListCellID";

@interface SpeakerViewController ()
<
RecordingHandlerDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic) RecordingHandler *handler;
@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *storageLocation;
@property (weak, nonatomic) IBOutlet UITextField *fileName;
@property (weak, nonatomic) IBOutlet UILabel *progressContent;
@property (weak, nonatomic) IBOutlet UITableView *playListTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playMode;

@property (nonatomic) DJIMediaFileListState state;
@property (nonatomic) DJISpeakerState *currentState;

@end

@implementation SpeakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.handler = [[RecordingHandler alloc] initWithSampleRate:44100 channelsPerFrame:1];
    self.handler.delegate = self;
    
    self.playListTableView.delegate = self;
    self.playListTableView.dataSource = self;
    
    [self.playListTableView registerNib:[UINib nibWithNibName:@"SpeakerAudioPlaylistTableViewCell" bundle:nil] forCellReuseIdentifier:SpeakerPlayListCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WeakRef(target);
    [[self fetchSpeaker] addFileListStateListener:self withQueue:dispatch_get_main_queue() andBlock:^(DJIMediaFileListState state) {
        WeakReturn(target);
        
        if (target.state &&
            state != DJIMediaFileListStateUpToDate &&
            target.state == DJIMediaFileListStateUpToDate) {
            [target refreshPlayListGUI];
        }
        
        target.state = state;
    }];
    
    [[self fetchSpeaker] refreshFileListWithCompletion:^(NSError * _Nullable error) {
        if (!error) {
            [target.playListTableView reloadData];
        }
    }];
    
    [[self fetchSpeaker] addSpeakerStateListener:self withQueue:dispatch_get_main_queue() andBlock:^(DJISpeakerState * _Nonnull state) {
        target.currentState = state;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[self fetchSpeaker] removeSpeakerStateListener:self];
    [[self fetchSpeaker] removeFileListStateListener:self];
}

- (IBAction)recordButtonClick:(id)sender {
    WeakRef(target);
    void (^transmissionOperation) () = ^() {
        WeakReturn(target);
        if (target.handler.isRecording) {
            [target.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
            [target.handler stop];
            [[target fetchSpeaker] markEOF];
        } else {
            if (!target.fileName.text || target.fileName.text.length <= 0) {
                ShowResult(@"File Name empty");
                return;
            }
            
            DJIAudioFileInfo *fileInfo = [[DJIAudioFileInfo alloc] init];
            fileInfo.fileName = target.fileName.text;
            fileInfo.storageLocation = (DJIAudioStorageLocation)target.storageLocation.selectedSegmentIndex;
            
            [[target fetchSpeaker] startTransmissionWithInfo:fileInfo startBlock:^{
                WeakReturn(target);
                [target.recordingButton setTitle:@"Stop Record" forState:UIControlStateNormal];
                [target.handler start];
            } onProgress:^(NSInteger dataSize) {
                WeakReturn(target);
                [target.progressContent setText:[NSString stringWithFormat:@"progress: %@", @(dataSize)]];
            } finish:^(NSInteger index) {
                ShowResult(@"transmission success index: %lu", index);
                [target.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
            } failure:^(NSError * _Nonnull error) {
                ShowResult(@"transmission failed: %@", error.description);
                [target.recordingButton setTitle:@"Start Record" forState:UIControlStateNormal];
            }];
        }
    };
    
    switch ([AVAudioSession sharedInstance].recordPermission) {
        case AVAudioSessionRecordPermissionDenied:
        case AVAudioSessionRecordPermissionUndetermined:
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        transmissionOperation();
                    });
                }
            }];
            
            return;
        }
            break;
            
        default:
            break;
    }
    
    transmissionOperation();
}

- (IBAction)chooseVolume:(id)sender {
    NSString *content = [NSString stringWithFormat:@"Volume: %@", @(self.currentState.volume)];
    WeakRef(target);
    [DemoAlertView showAlertViewWithMessage:content titles:@[@"Cancel", @"OK"] textFields:@[@"input volue [0-100]"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        WeakReturn(target);
        if (buttonIndex == 0) {
            return;
        }
        
        [[target fetchSpeaker] setVolume:textFields[0].text.integerValue withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"set volume error: %@", error.description);
            } else {
                ShowResult(@"success");
            }
        }];
    }];
}

#pragma mark - RecordingHandlerDelegate

- (void)recordingHandler:(RecordingHandler *)handler output:(NSData *)pcmData {
    [[self fetchSpeaker] paceData:pcmData];
}

- (DJISpeaker *)fetchSpeaker {
    DJIAccessoryAggregation *accessory = [DemoComponentHelper fetchAccessoryAggregation];
    return accessory.speaker;
}

#pragma mark - Refresh

- (void)refreshPlayListGUI {
    WeakRef(target);
    [[self fetchSpeaker] refreshFileListWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"refresh speaker file list error: %@", error);
        } else {
            [target.playListTableView reloadData];
        }
    }];
}

- (void)updateAllUI {
    if (!self.currentState) {
        return;
    }
    
    [self.playMode setSelectedSegmentIndex:self.currentState.playingMode];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<DJIAudioMediaFile*> *files = [self fetchSpeaker].fileListSnapshot;
    
    if (indexPath.row >= files.count) {
        return nil;
    }
    
    SpeakerAudioPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SpeakerPlayListCellID];
    
    DJIAudioMediaFile *message  = files[indexPath.row];
    cell.fileName.text          = message.fileName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<DJIAudioMediaFile*> *files = [self fetchSpeaker].fileListSnapshot;
    DJIAudioMediaFile *message         = files[indexPath.row];
    
    [[self fetchSpeaker] play:message.index withCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Play Audio error: %@", error);
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self fetchSpeaker].fileListSnapshot ? [self fetchSpeaker].fileListSnapshot.count : 0;
}

@end
