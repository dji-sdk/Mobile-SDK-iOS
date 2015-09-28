//
//  Phantom3MediaTestTableViewController.m
//  DJISdkDemo
//
//  Created by Ares on 15/5/19.
//  Copyright (c) 2015年 DJI. All rights reserved.
//

#import "Phantom3MediaTestTableViewController.h"
#import "DJIDemoHelper.h"

@interface Phantom3MediaTestTableViewController ()

@property(nonatomic, weak) IBOutlet UITableView* tableView;

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, strong) NSMutableArray* mediaList;
@property(nonatomic, assign) int currentMediaIndex;

@property(nonatomic, strong) DJIDrone* drone;

@property(nonatomic, strong) UIAlertView* downloadProgressAlert;
@property(nonatomic, strong) MBProgressHUD* progressHUD;

@end

@implementation Phantom3MediaTestTableViewController

-(id) initWithDrone:(DJIDrone*)drone
{
    self = [super init];
    if (self) {
        self.drone = drone;
        self.drone.delegate = self;
        self.drone.camera.delegate = self;
    }
    
    return self;
}

-(id) initWithDroneType:(DJIDroneType)type
{
    self = [super init];
    if (self) {
        self.drone = [[DJIDrone alloc] initWithType:type];
        self.drone.delegate = self;
        self.drone.camera.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    self.mediaList = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.drone connectToDrone];
    [self.drone.camera startCameraSystemStateUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.drone.camera stopCameraSystemStateUpdates];
    [self.drone disconnectToDrone];
}

-(void) showProgress
{
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.progressHUD show:YES];
    [self.view addSubview:self.progressHUD];
}

-(void) hideProgress
{
    if (self.progressHUD) {
        [self.progressHUD hide:YES];
        [self.progressHUD removeFromSuperview];
        self.progressHUD = nil;
    }
}

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
}

-(void) loadMediaList
{
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;

    [self showProgress];
    
    if ([self.drone.camera respondsToSelector:@selector(fetchMediaListWithResultBlock:)]) {
        WeakRef(obj);
        typedef void (^FetchMediaListHandler)(NSArray*, NSError*);
        FetchMediaListHandler handler = ^(NSArray *mediaList, NSError *error) {
            WeakReturn(obj);
            if (error == nil) {
                [obj updateMediaList:mediaList];
            }
            else
            {
                ShowResult(@"Fetch Media Failed: %d", error.code);
            }
            
            [obj hideProgress];
        };
        
        [self.drone.camera performSelector:@selector(fetchMediaListWithResultBlock:) withObject:handler];
    }
}

-(void) updateMediaList:(NSArray*)mediaList
{
    [self.mediaList removeAllObjects];
    [self.mediaList addObjectsFromArray:mediaList];
    [self.tableView reloadData];
    
    [self fetchThumbnailOneByOne];
}

-(void) fetchThumbnailOneByOne
{
    self.currentMediaIndex = -1;
    [self fetchNextThumbnail];
}

-(void) fetchNextThumbnail
{
    self.currentMediaIndex ++;
    if (self.currentMediaIndex < self.mediaList.count) {
        DJIMedia* currentMedia = [self.mediaList objectAtIndex:self.currentMediaIndex];
        if (currentMedia.thumbnail != nil) {
            [self fetchNextThumbnail];
        }
        else
        {
            WeakRef(obj);
            [currentMedia fetchThumbnail:^(NSError *error) {
                WeakReturn(obj);
                if (error) {
                    ShowResult(@"Error:%@", error);
                }
                [obj.tableView reloadData];
                [obj fetchNextThumbnail];
            }];
        }
    }
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (self.drone.droneType == DJIDrone_Inspire || self.drone.droneType == DJIDrone_Phantom3Professional) {
        if (systemState.workMode != CameraWorkModeDownload2) {
            DJIPhantom3ProCamera* phantom3ProCamera = (DJIPhantom3ProCamera*)self.drone.camera;
            [phantom3ProCamera setCameraWorkMode:CameraWorkModeDownload2 withResult:^(DJIError *error) {
            }];
        }
        if (systemState.workMode == CameraWorkModeDownload2) {
            
            [self loadMediaList];
        }
    }
    else if (self.drone.droneType == DJIDrone_Inspire)
    {
        if (systemState.workMode != CameraWorkModeDownload2) {
            DJIPhantom3ProCamera* phantom3ProCamera = (DJIPhantom3ProCamera*)self.drone.camera;
            [phantom3ProCamera setCameraWorkMode:CameraWorkModeDownload2 withResult:^(DJIError *error) {
            }];
        }
        if (systemState.workMode == CameraWorkModeDownload2) {
            
            [self loadMediaList];
        }
    }
    else if (self.drone.droneType == DJIDrone_Phantom3Advanced)
    {
        if (systemState.workMode != CameraWorkModeDownload) {
            DJIPhantom3AdvancedCamera* phantom3AdvancedCamera = (DJIPhantom3AdvancedCamera*)self.drone.camera;
            [phantom3AdvancedCamera setCameraWorkMode:CameraWorkModeDownload withResult:^(DJIError *error) {
            }];
        }
        if (systemState.workMode == CameraWorkModeDownload) {
            [self loadMediaList];
        }
    }

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mediaList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    
    DJIMedia* media = [self.mediaList objectAtIndex:indexPath.row];
    cell.textLabel.text = media.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Create Date: %@\tSize: %0.1fMB", media.createTime, media.fileSize / 1024.0 / 1024.0];
    if (media.thumbnail == nil) {
        [cell.imageView setImage:[UIImage imageNamed:@"dji.png"]];
    }
    else
    {
        [cell.imageView setImage:media.thumbnail];
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DJIMedia* media = [mMediaList objectAtIndex:indexPath.row];
//
//    [self.phantom3AdvancedCamera deleteMedias:@[media] withResult:^(NSArray *failureDeletes, DJIError *error) {
//        ShowResult(@"Delete Media:%@ FailureDelete:%d", error.errorDescription, failureDeletes.count);
//    }];
//    
//    return;

    DJIMedia* currentMedia = [self.mediaList objectAtIndex:indexPath.row];
    __block int totalDownloadSize = 0;
    __block NSMutableData* downloadData = [[NSMutableData alloc] init];
    BOOL isPhoto = currentMedia.mediaType == MediaTypeJPG;
    WeakRef(obj);
    if (isPhoto) {
        [self showProgress];
        [currentMedia fetchPreviewImageWithResult:^(UIImage *image, NSError * error) {
            [obj hideProgress];
            if (error == nil) {
                [obj showPhotoWithData:UIImageJPEGRepresentation(image, 1)];
            }
            else
            {
                ShowResult(@"Error:%@", error);
            }
            
        }];
        return;
    }

    if (self.downloadProgressAlert == nil) {
        self.downloadProgressAlert = [[UIAlertView alloc] initWithTitle:@"Fetch Media Data" message:@"0.0%" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [self.downloadProgressAlert show];
    }
    
    [currentMedia fetchMediaData:^(NSData *data, BOOL *stop, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WeakReturn(obj);
            if (error) {
                [obj.downloadProgressAlert setMessage:@"Error"];
                [obj performSelector:@selector(dismissDownloadAlert) withObject:nil afterDelay:2.0];
            }
            else
            {
                if (isPhoto) {
                    [downloadData appendData:data];
                }
                totalDownloadSize += data.length;
                float progress = totalDownloadSize * 100.0 / currentMedia.fileSize;
                [obj.downloadProgressAlert setMessage:[NSString stringWithFormat:@"%0.1f%%", progress]];
                if (totalDownloadSize == currentMedia.fileSize) {
                    [obj dismissDownloadAlert];
                    if (isPhoto) {
                        [obj showPhotoWithData:downloadData];
                    }
                }
            }
        });
    }];
}

-(void) dismissDownloadAlert
{
    [self.downloadProgressAlert dismissWithClickedButtonIndex:-1 animated:YES];
    self.downloadProgressAlert = nil;
}

-(void) showPhotoWithData:(NSData*)data
{
    if (data) {
        UIImage* image = [UIImage imageWithData:data];
        if (image) {
            UIView* bkgndView = [[UIView alloc] initWithFrame:self.view.bounds];
            bkgndView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewTap:)];
            [bkgndView addGestureRecognizer:tapGesture];

            float width = self.view.bounds.size.width * 0.7;
            float height = self.view.bounds.size.height * 0.7;
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            imgView.image = image;
            imgView.center = bkgndView.center;
            imgView.backgroundColor = [UIColor lightGrayColor];
            imgView.layer.borderWidth = 2.0;
            imgView.layer.borderColor = [UIColor blueColor].CGColor;
            imgView.layer.cornerRadius = 4.0;
            imgView.layer.masksToBounds = YES;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            
            [bkgndView addSubview:imgView];
            [self.view addSubview:bkgndView];
        }
        else
        {
            ShowResult(@"Image Crashed");
        }
    }
}

-(void) onImageViewTap:(UIGestureRecognizer*)recognized
{
    UIView* view = recognized.view;
    [view removeFromSuperview];
}

@end
