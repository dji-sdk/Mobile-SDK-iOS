//
//  MediaTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-19.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "PhantomMediaTestViewController.h"
#import "MediaPreviewViewController.h"
#import "DJIDemoHelper.h"
#import <DJISDK/DJISDK.h>

#define DEFAULT_IMAGE [UIImage imageNamed:@"dji.png"]

@interface MediaTableViewCell : UITableViewCell
{
    UIActivityIndicatorView* _loadingIndicator;
}

@property(nonatomic, retain) DJIMedia* media;

-(void) startLoadThumbneilWithLoadingManager:(MediaLoadingManager*)loadingManager;

@end

@implementation MediaTableViewCell

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.imageView setFrame:CGRectMake(10, (self.frame.size.height - 45)*0.5, 45, 45)];
        self.imageView.image = DEFAULT_IMAGE;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(10, (self.frame.size.height - 45)*0.5, 45, 45)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect labelRect = self.textLabel.frame;
    labelRect.origin.x = self.imageView.frame.size.width + 25;
    self.textLabel.frame = labelRect;
}

-(void) startLoadThumbneilWithLoadingManager:(MediaLoadingManager*)loadingManager
{
    if (self.media && self.media.thumbnail) {
        self.imageView.image = self.media.thumbnail;
        return;
    }
    if (loadingManager && self.media) {
        [self showLoadingIndicator];
        DJIMedia* tempMedia = self.media;
        [loadingManager addTaskForMedia:tempMedia withBlock:^{
            [tempMedia fetchThumbnail:^(NSError *error) {
                if (error == nil) {
                    if (tempMedia == self.media) {
                        if (self.media.thumbnail) {
                            [self performSelectorOnMainThread:@selector(setThumbnail) withObject:nil waitUntilDone:YES];
                        }
                    }
                }
                else
                {
                    NSLog(@"Fetch Thumbnail:%@", error);
                }
            }];
        }];
    }
}

-(void) setThumbnail
{
    [self hideLoadingIndicator];
    self.imageView.image = self.media.thumbnail;
}

-(void) setMedia:(DJIMedia *)media
{
    _media = media;
    if (_media) {
        self.textLabel.text = _media.fileName;
    }
    else
        self.textLabel.text = nil;
}

-(void) showLoadingIndicator
{
    if (_loadingIndicator == nil) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _loadingIndicator.center = CGPointMake(self.imageView.frame.size.width*0.5, self.imageView.frame.size.height*0.5);
    [self.imageView addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

-(void) hideLoadingIndicator
{
    if (_loadingIndicator) {
        [_loadingIndicator stopAnimating];
        [_loadingIndicator removeFromSuperview];
    }
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.media = Nil;
    [self hideLoadingIndicator];
    self.imageView.image = DEFAULT_IMAGE;
}

@end

@implementation PhantomMediaTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.camera.delegate = self;
    _drone.delegate = self;
    _loadingManager = [[MediaLoadingManager alloc] initWithThreadsForImage:4 threadsForVideo:4];
    self.isFetchingMedias = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_drone connectToDrone];
    [_drone.camera startCameraSystemStateUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
}

-(void) showLoadingIndicator
{
    if (_loadingIndicator == nil) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _loadingIndicator.center = self.view.center;
    [self.view addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

-(void) hideLoadingIndicator
{
    if (_loadingIndicator) {
        [_loadingIndicator stopAnimating];
        [_loadingIndicator removeFromSuperview];
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_mediasList) {
        return _mediasList.count;
    }
    return 0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* s_identifier = @"identifier";
    MediaTableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:s_identifier];
    if (cell == nil) {
        cell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s_identifier];
    }
    
    DJIMedia* media = [_mediasList objectAtIndex:indexPath.row];
    [cell setMedia:media];
    [cell startLoadThumbneilWithLoadingManager:_loadingManager];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DJIMedia* media = [_mediasList objectAtIndex:indexPath.row];
    MediaPreviewViewController* previewController = [[MediaPreviewViewController alloc] initWithNibName:@"MediaPreviewViewController" bundle:nil];
    [previewController setMedia:media];
    [self.navigationController pushViewController:previewController animated:YES];
}

-(void) updateMedias
{
    if (_mediasList) {
        return;
    }
    
    if (self.isFetchingMedias) {
        return;
    }
    NSLog(@"Start Fetch Medias...");
    self.isFetchingMedias = YES;
    [self showLoadingIndicator];
    
    NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
    
    WeakRef(obj);
    DJIPhantomCamera* phantomCamera = (DJIPhantomCamera*)_drone.camera;
    [phantomCamera fetchMediaListWithResultBlock:^(NSArray *mediaList, NSError *error) {
        WeakReturn(obj);
        [obj hideLoadingIndicator];
        if (error) {
            NSLog(@"Fetch Media List Failured:%@", error);
        }
        else
        {
            [obj onFetchCompleteWithMedias:mediaList];
        }

        obj.isFetchingMedias = NO;
        
        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval timeCost = timeEnd - timeBegin;
        int mediaCount = 1;
        if (mediaList) {
            mediaCount = (int)mediaList.count;
        }
        NSLog(@"Stop Fetch Medias, Total:%dms Average:%dms", (int)(timeCost*1000), (int)(timeCost*1000/mediaCount));
    }];
}

-(void) onFetchCompleteWithMedias:(NSArray*)mediaList
{
    if (mediaList) {
        _mediasList = mediaList;
        [self.tableView reloadData];
        NSLog(@"MediaDirs: %@", _mediasList);
    }
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSucceeded) {
        [_drone.camera setCamerMode:CameraUSBMode withResultBlock:^(DJIError *error) {
            
        }];
    }
}

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (!systemState.isUSBMode) {
        NSLog(@"Set USB Mode");
        [_drone.camera setCamerMode:CameraUSBMode withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Succeeded) {
                NSLog(@"Set USB Mode Successed");
            }
        }];
    }
    if (!systemState.isSDCardExist) {
        NSLog(@"SD Card Not Insert");
        return;
    }
    if (systemState.isConnectedToPC) {
        NSLog(@"USB Connected To PC");
        return;
    }
    
    if (systemState.isUSBMode) {
        [self updateMedias];
    }
}
@end

@interface MediaContextLoadingTask : NSObject

@property (strong, nonatomic) DJIMedia *media;
@property (copy, nonatomic) MediaLoadingManagerTaskBlock block;

@end

@implementation MediaContextLoadingTask

@end

@implementation MediaLoadingManager

- (id)initWithThreadsForImage:(NSUInteger)imageThreads threadsForVideo:(NSUInteger)videoThreads {
    self = [super init];
    if (self) {
        NSAssert(imageThreads >= 1, @"number of threads for image must be greater than 0.");
        NSAssert(videoThreads >= 1, @"number of threads for video must be greater than 0.");
        
        _imageThreads = imageThreads;
        _videoThreads = videoThreads;
        _mediaIndex = 0;
        
        NSMutableArray *operationQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager image %lu", (unsigned long)i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        for (NSUInteger i = 0; i < _videoThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager video %lu", (unsigned long)i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        _operationQueues = operationQueues;
        
        NSMutableArray *taskQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads + _videoThreads; i++) {
            [taskQueues addObject:[NSMutableArray array]];
        }
        
        _taskQueues = taskQueues;
    }
    return self;
}

- (void)addTaskForMedia:(DJIMedia *)media withBlock:(MediaLoadingManagerTaskBlock)block {
    NSUInteger threadIndex;
    if (media.mediaType == MediaTypeJPG) {
        threadIndex = _mediaIndex % _imageThreads;
    }
    else {
        threadIndex = _imageThreads + _mediaIndex % _videoThreads;
    }
    _mediaIndex++;
    
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex];
    @synchronized(taskQueue) {
        MediaContextLoadingTask *task = [[MediaContextLoadingTask alloc] init];
        task.media = media;
        task.block = block;
        
        [taskQueue addObject:task];
    }
    
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex];
    if (operationQueue.operationCount == 0) {
        [self driveTaskQueue:@(threadIndex)];
    }
}

- (void)driveTaskQueue:(NSNumber *)threadIndex {
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex.integerValue];
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex.integerValue];
    
    @synchronized(taskQueue) {
        if (taskQueue.count == 0) {
            return;
        }
        
        MediaContextLoadingTask *task = [taskQueue lastObject];
        [taskQueue removeLastObject];
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            task.block();
            [self driveTaskQueue:threadIndex];
        }];
        [operationQueue addOperation:operation];
    }
}

- (void)cancelAllTasks {
    for (NSMutableArray *taskQueue in _taskQueues) {
        @synchronized(taskQueue) {
            [taskQueue removeAllObjects];
        }
    }
    
    for (NSOperationQueue *queue in _operationQueues) {
        [queue cancelAllOperations];
    }
}

@end

