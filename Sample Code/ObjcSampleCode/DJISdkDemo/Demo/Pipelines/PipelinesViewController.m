//
//  PipelinesViewController.m
//  DJISdkDemo
//
//  Copyright © 2020 DJI. All rights reserved.
//

#import "PipelinesViewController.h"
#import "PipelineStatistical.h"
#import "PipelineTableViewCell.h"
#import <DJISDK/DJISDK.h>
#import "PipelineDuplexLogic.h"
#import "DemoUtilityMacro.h"
#import "DemoAlertView.h"

static NSString *PipelineCellReuseId = @"PipelineCellReuseId";
NSString * const PipelinesKey = @"Pipelines";

@interface PipelinesViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) dispatch_source_t statisticalTimer;

@property (nonatomic) NSMutableDictionary<NSNumber *, PipelineDuplexLogic *> *duplexManager;

@end

@implementation PipelinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.duplexManager = [NSMutableDictionary dictionary];
    
    [self.existPipelines registerNib:[UINib nibWithNibName:@"PipelineTableViewCell" bundle:nil] forCellReuseIdentifier:PipelineCellReuseId];
    self.existPipelines.delegate = self;
    self.existPipelines.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.pipelineId.keyboardType = UIKeyboardTypeNumberPad;
    
    WeakRef(target);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        WeakReturn(target);
        
        [target refreshStatical];
    });
    dispatch_resume(timer);
    self.statisticalTimer = timer;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.statisticalTimer) {
        dispatch_source_cancel(self.statisticalTimer);
        self.statisticalTimer = nil;
    }
    
    [self.duplexManager enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, PipelineDuplexLogic * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj stopDownload:nil];
        [obj stopUpload:nil];
    }];
}

- (IBAction)connectPipeline:(UIButton *)sender {
    NSMutableDictionary<NSString*, DJIPipelines*> *dictionary = [NSMutableDictionary dictionary];
    switch (self.deviceType.selectedSegmentIndex) {
        case DJIPipelineDeviceTypeOnboard:
        {
            DJIPipelines *pipelines = [[self class] aircraft].flightController.onboardSDKDevice.pipelines;
            WeakRef(target);
            [pipelines connect:self.pipelineId.text.intValue pipelineType:(DJITransmissionControlType)self.deviceType.selectedSegmentIndex withCompletion:^(DJIPipeline * _Nullable pipeline, NSError * _Nullable error) {
                WeakReturn(target);
                
                if (error) {
                    ShowResult(@"Connect Onboard failure: %@", error.description);
                } else {
                    [target.existPipelines reloadData];
                }
            }];
        }
            break;
        case DJIPipelineDeviceTypePayload:
        {
            [[[self class] aircraft].payloads enumerateObjectsUsingBlock:^(DJIPayload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.pipelines) {
                    dictionary[[NSString stringWithFormat:@"Payload index: %lu", obj.index]] = obj.pipelines;
                }
            }];
        }
            break;
            
        default:
            break;
    }
    
    [self.pipelineId resignFirstResponder];
    
    if (dictionary) {
        NSMutableArray *chooseArr = [NSMutableArray arrayWithArray:dictionary.allKeys];
        [chooseArr addObject:@"Cancel"];
        WeakRef(target);
        [DemoAlertView showAlertViewWithMessage:@"Connect Pipeline" titles:chooseArr action:^(NSUInteger buttonIndex) {
            WeakReturn(target);
            if (buttonIndex == chooseArr.count - 1) {
                return;
            }
            
            DJIPipelines *pipelines = dictionary[chooseArr[buttonIndex]];
            if (!pipelines) {
                return;
            }
            
            uint16_t channelId = target.pipelineId.text.length > 0 ? target.pipelineId.text.intValue : 49153;
            
            WeakRef(target);
            [pipelines connect:channelId pipelineType:(DJITransmissionControlType)target.transmissionType.selectedSegmentIndex withCompletion:^(DJIPipeline * _Nullable pipeline, NSError * _Nullable error) {
                WeakReturn(target);
                
                if (error) {
                    ShowResult(@"Connect Payload failure: %@", error.description);
                } else {
                    [target.existPipelines reloadData];
                }
            }];
        }];
    }
}

//MARK: - Statiscal

- (void)refreshStatical {
    NSMutableString *contentString = [NSMutableString string];
    
    [self.duplexManager enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, PipelineDuplexLogic * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.isDownloading) {
            obj.downloadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        }
        
        if (obj.isUploading) {
            obj.uploadStatistical.endTime = CFAbsoluteTimeGetCurrent();
        }
        
        [contentString appendFormat:@"==== %@ ====\n", obj.downloadTitle];
        [contentString appendFormat:@"===== Download Operation =====\n"];
        [contentString appendFormat:@"Number of successful packages received in the last 1 second: %ld\n", obj.downloadStatistical.numberOfPacketsSuccessfully];
        [contentString appendFormat:@"Number of bytes successfully received in the last 1 second: %@\n", [NSByteCountFormatter stringFromByteCount:obj.downloadStatistical.numberOfBytesSuccessfully countStyle:NSByteCountFormatterCountStyleFile]];
        [contentString appendFormat:@"Total number of successful bytes received：%@\n", [NSByteCountFormatter stringFromByteCount:obj.downloadStatistical.totalSuccessful countStyle:NSByteCountFormatterCountStyleFile]];
        double receiveDuration = obj.downloadStatistical.endTime - obj.downloadStatistical.startTime;
        [contentString appendFormat:@"Receive already running %f 秒\n", receiveDuration];
        double averageReceive = obj.downloadStatistical.totalSuccessful / receiveDuration;
        [contentString appendFormat:@"Average reception speed per second %@\n", [NSByteCountFormatter stringFromByteCount:averageReceive countStyle:NSByteCountFormatterCountStyleFile]];
        if (obj.isDownloadTransimssionFailure || obj.isDownloadTransmissionSuccessful) {
            [contentString appendFormat:@"==== Download file final results ====\n"];
            [contentString appendString:obj.downloadFinalResult];
            [contentString appendString:@"\n===========================\n"];
        }
        [contentString appendString:@"===========================\n"];
        [contentString appendFormat:@"==== %@ ====\n", obj.uploadTitle];
        [contentString appendFormat:@"===== Upload Operation =====\n"];
        [contentString appendFormat:@"Number of successful packages sent in the last 1 second: %ld\n", obj.uploadStatistical.numberOfPacketsSuccessfully];
        [contentString appendFormat:@"Number of bytes successfully sent in the last 1 second: %@\n", [NSByteCountFormatter stringFromByteCount:obj.uploadStatistical.numberOfBytesSuccessfully countStyle:NSByteCountFormatterCountStyleFile]];
        [contentString appendFormat:@"Total number of successful bytes sent：%@\n", [NSByteCountFormatter stringFromByteCount:obj.uploadStatistical.totalSuccessful countStyle:NSByteCountFormatterCountStyleFile]];
        double sentDuration = obj.uploadStatistical.endTime - obj.uploadStatistical.startTime;
        [contentString appendFormat:@"Already running send %f 秒\n", sentDuration];
        double averageSent = obj.uploadStatistical.totalSuccessful / sentDuration;
        [contentString appendFormat:@"Average sending speed per second %@\n", [NSByteCountFormatter stringFromByteCount:averageSent countStyle:NSByteCountFormatterCountStyleFile]];
        [contentString appendString:@"===========================\n"];
        if (obj.isUploadTransmissionSuccessful || obj.isUploadTransimssionFailure) {
            [contentString appendFormat:@"==== Upload the final result of the file ====\n"];
            [contentString appendString:obj.uploadFinalResult];
            [contentString appendString:@"\n===========================\n"];
        }
        
        [obj.uploadStatistical clearRegularData];
        [obj.downloadStatistical clearRegularData];
    }];
    
    self.logView.text = contentString;
}

//MARK: - UITableViewDelegate

//MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DJIAircraft *product = [[self class] aircraft];
    if (product == nil) {
        return 0;
    }
    
    __block NSInteger pipelinesCount = 0;
    if (product.flightController != nil && product.flightController.onboardSDKDevice.pipelines != nil) {
        pipelinesCount ++;
    }
    
    [product.payloads enumerateObjectsUsingBlock:^(DJIPayload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pipelines != nil) {
            pipelinesCount ++;
        }
    }];
    
    return pipelinesCount;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self class] getPipelinesSectionBySectionIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DJIPipelines *pipelines = [[self class] getPipelinesBySectionIndex:section];
    if (pipelines == nil) {
        return 0;
    }
    
    return pipelines.pipelines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PipelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PipelineCellReuseId];
    if (cell == nil) {
        cell = [[PipelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PipelineCellReuseId];
    }
    
    DJIPipelines *pipelines = [[self class] getPipelinesBySectionIndex:indexPath.section];
    NSArray *allKeys = [pipelines.pipelines.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger id1 = [obj1 integerValue];
        NSInteger id2 = [obj2 integerValue];
        
        if (id1 > id2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    DJIPipeline *pipeline = pipelines.pipelines[allKeys[indexPath.row]];
    
    cell.download.tag = (indexPath.section << 8 * 4 | [allKeys[indexPath.row] intValue]);
    cell.upload.tag = (indexPath.section << 8 * 4 | [allKeys[indexPath.row] intValue]);
    cell.disconnect.tag = (indexPath.section << 8 * 4 | [allKeys[indexPath.row] intValue]);
    cell.content.text = [NSString stringWithFormat:@"id: %@ transmission: %@", @(pipeline.Id), [[self class] descriptionForPipelineType:pipeline.transmissionType]];
    
    [cell.download addTarget:self action:@selector(onDownloadEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.upload addTarget:self action:@selector(onUploadEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell.disconnect addTarget:self action:@selector(onDisconnectEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//MARK: - Button Event

- (void)onDownloadEvent:(UIButton *)button {
    NSInteger section = button.tag >> 8 * 4;
    
    DJIPipelines *pipelines = [[self class] getPipelinesBySectionIndex:section];
    if (!pipelines) {
        ShowResult(@"should have the pipelines");
        return;
    }
    
    NSInteger Id = (button.tag & 0xFFFFFFFF);
    DJIPipeline *pipeline = (pipelines.pipelines != nil) ? pipelines.pipelines[@(Id)] : nil;
    if (pipeline == nil) {
        ShowResult(@"should have the pipeline: %lu", Id);
        return;
    }
    
    if (pipeline == nil) {
        ShowResult(@"can't find the pipeline: %lu", Id);
        return;
    }
    
    __block PipelineDuplexLogic *downloadLogic = self.duplexManager[@(button.tag)];
    if (downloadLogic != nil && downloadLogic.isDownloading) {
        ShowResult(@"Stop download Logic");
        [downloadLogic stopDownload:pipeline];
        return;
    }
    
    WeakRef(target);
    [DemoAlertView showAlertViewWithMessage:@"Download File" titles:@[@"Start", @"Cancel"] textFields:@[@"remote file name[default: test.mp4]"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        WeakReturn(target);
        if (buttonIndex == 1) {
            return;
        }
        
        NSString *fileName = textFields[0].text.length > 0 ? textFields[0].text : @"test.mp4";
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];

        NSString *title = [NSString stringWithFormat:@"Download %@ id: %@", [[self class] getPipelinesSectionBySectionIndex:section], @(Id)];
        
        if (downloadLogic == nil) {
            downloadLogic = [[PipelineDuplexLogic alloc] init];
            self.duplexManager[@(button.tag)] = downloadLogic;
        }
        
        downloadLogic.downloadTitle = title;
        [downloadLogic download:fileName localFilePath:[documentPath stringByAppendingPathComponent:fileName] pipeline:pipeline withFinishBlock:^{
            
        } withFailureBlock:^(DJIPipeline * _Nullable pipeline, NSString * _Nullable error) {
            
        }];
    }];
}

- (void)onUploadEvent:(UIButton *)button {
    NSInteger section = button.tag >> 8 * 4;
    
    DJIPipelines *pipelines = [[self class] getPipelinesBySectionIndex:section];
    if (!pipelines) {
        ShowResult(@"should have the pipelines");
        return;
    }
    
    NSInteger Id = (button.tag & 0xFFFFFFFF);
    DJIPipeline *pipeline = (pipelines.pipelines != nil) ? pipelines.pipelines[@(Id)] : nil;
    if (pipeline == nil) {
        ShowResult(@"can't find the pipeline: %lu", Id);
        return;
    }
    
    __block PipelineDuplexLogic *uploadLogic = self.duplexManager[@(button.tag)];
    if (uploadLogic != nil && uploadLogic.isUploading) {
        ShowResult(@"Stop Upload Logic");
        [uploadLogic stopUpload:pipeline];
        return;
    }
    
    NSArray<NSString *> *files = @[
        @"test1.mp3",
        @"test2.mp3",
        @"test3.mp3",
        @"test4.mp3",
    ];
    NSMutableArray<NSString*> *existFiles = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[[obj lastPathComponent] stringByDeletingPathExtension] ofType:[obj pathExtension]];
        if ([fileManager fileExistsAtPath:filePath]) {
            [existFiles addObject:filePath];
        }
    }];
    
    if (existFiles.count <= 0) {
        ShowResult(@"files not exist.");
        return;
    }
    
    NSMutableArray *options = [NSMutableArray array];
    [existFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger fileSize = [[fileManager attributesOfItemAtPath:obj error:nil] fileSize];
        NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
        [options addObject:[NSString stringWithFormat:@"%@ : %@", [obj lastPathComponent], fileSizeStr]];
    }];
    [options addObject:@"Custom file"];
    [options addObject:@"Cancel"];
    
    NSString *title = [NSString stringWithFormat:@"Upload %@ id: %@", [[self class] getPipelinesSectionBySectionIndex:section], @(Id)];
    WeakRef(target);
    [DemoAlertView showAlertViewWithMessage:title titles:options textFields:@[@"Custom file", @"the length of the piece(3000 byte)", @"freqency(2 HZ)"] action:^(NSArray<UITextField *> * _Nullable textFields, NSUInteger buttonIndex) {
        WeakReturn(target);
        if (buttonIndex == options.count - 1) {
            return;
        }
        
        NSString *filePath = nil;
        if (buttonIndex == options.count - 2) {
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *customFilePath = [documentPath stringByAppendingPathComponent:textFields[0].text];
            
            if ([fileManager fileExistsAtPath:customFilePath] == NO) {
                ShowResult(@"file not exist: %@", customFilePath);
                return;
            }
            
            filePath = customFilePath;
        } else {
            filePath = existFiles[buttonIndex];
        }
        
        if (uploadLogic == nil) {
            uploadLogic = [[PipelineDuplexLogic alloc] init];
            self.duplexManager[@(button.tag)] = uploadLogic;
        }
        
        NSInteger pieceLength = textFields[1].text.length > 0 ? textFields[1].text.integerValue : 3000;
        double frequency = textFields[2].text.length > 0 ? textFields[2].text.doubleValue : 2.f;
        
        uploadLogic.uploadTitle = title;
        [uploadLogic uploadFile:filePath
                       pipeline:pipeline
                    pieceLength:pieceLength
                      frequency:frequency
                withFinishBlock:^{
            
        } withFailureBlock:^(DJIPipeline * _Nullable pipeline, NSString * _Nullable error) {
            
        }];
    }];
}

- (void)onDisconnectEvent:(UIButton *)button {
    if (self.duplexManager[@(button.tag)] != nil) {
        PipelineDuplexLogic *logic = self.duplexManager[@(button.tag)];
        logic.stopUpload = YES;
        logic.stopDownload = YES;
        [self.duplexManager removeObjectForKey:@(button.tag)];
    }
    
    NSInteger section = button.tag >> 8 * 4;
    
    DJIPipelines *pipelines = [[self class] getPipelinesBySectionIndex:section];
    if (!pipelines) {
        ShowResult(@"should have the pipelines");
        return;
    }
    
    NSInteger Id = (button.tag & 0xFFFFFFFF);
    DJIPipeline *pipeline = (pipelines.pipelines != nil) ? pipelines.pipelines[@(Id)] : nil;
    if (pipeline == nil) {
        ShowResult(@"should have the pipeline: %lu", Id);
        return;
    }
    
    WeakRef(target);
    [pipelines disconnect:Id withCompletion:^(NSError * _Nullable error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"disconnect failure: %@", error.description);
        } else {
            ShowResult(@"disconnect success");
        }
        
        [target.existPipelines reloadData];
    }];
}

//MARK: - Utils

+ (DJIPipelines *)getPipelinesBySectionIndex:(NSInteger)section {
    DJIAircraft *product = [self aircraft];
    if (product == nil) {
        return nil;
    }
    
    __block NSInteger pipelinesCount = 0;
    if (product.flightController != nil && product.flightController.onboardSDKDevice.pipelines != nil) {
        pipelinesCount ++;
    }
    
    if (section == pipelinesCount - 1) {
        return product.flightController.onboardSDKDevice.pipelines;
    }
    
    __block DJIPipelines *pipelines = nil;
    [product.payloads enumerateObjectsUsingBlock:^(DJIPayload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pipelines != nil) {
            pipelinesCount ++;
        }
        
        if (section == pipelinesCount - 1) {
            pipelines = obj.pipelines;
            (*stop) = YES;
            return;
        }
    }];
    
    return pipelines;
}

+ (NSString *)getPipelinesSectionBySectionIndex:(NSInteger)section {
    DJIAircraft *product = [self aircraft];
    if (product == nil) {
        return @"Unknown";
    }
    
    __block NSInteger pipelinesCount = 0;
    if (product.flightController != nil && product.flightController.onboardSDKDevice.pipelines != nil) {
        pipelinesCount ++;
    }
    
    if (section == pipelinesCount - 1) {
        return @"Onboard SDK";
    }
    
    __block NSString *sectionString = @"Unknown";
    [product.payloads enumerateObjectsUsingBlock:^(DJIPayload * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pipelines != nil) {
            pipelinesCount ++;
        }
        
        if (section == pipelinesCount - 1) {
            sectionString = [NSString stringWithFormat:@"Payload SDK index: %lu", (unsigned long)obj.index];
            (*stop) = YES;
            return;
        }
    }];
    
    return sectionString;
}

+ (DJIAircraft *)aircraft {
    DJIBaseProduct *product = [DJISDKManager product];
    if ([product isKindOfClass:[DJIAircraft class]]) {
        return (DJIAircraft *)product;
    }
    
    return nil;
}

+ (NSString *)descriptionForPipelineType:(DJITransmissionControlType)type {
    switch (type) {
        case DJITransmissionControlTypeUnreliable:
            return @"Unreliable";
        case DJITransmissionControlTypeStable:
            return @"Stable";
            
        default:
            break;
    }
    
    return nil;
}

@end
