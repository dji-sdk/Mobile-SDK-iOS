//
//  CameraFetchMediaViewController.m
//  DJISdkDemo
//
//  Copyright © 2015 DJI. All rights reserved.
//
/**
 *  This file demonstrates how to fetch a file in DJIMediaManager. The basic workflow is as follows:
 *  1. Check if the current camera mode is DJICameraModeMediaDownload. If it is not, change it to DJICameraModeMediaDownload.
 *  2. Once the mode is correct, before starting to access a specific file, we need to fetch the list for all media files first. 
 *  3. After the media list is fetched, we find a JPEG media file from the list. Please ensure that there is at least one JPEG in the SD card. 
 *  4. If one JPEG media file is found, user can choose to fetch its thumbnail, preview or the full image. 
 */
#import <DJISDK/DJISDK.h>
#import "DemoUtility.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "CameraFetchMediaViewController.h"

@interface CameraFetchMediaViewController ()

@property (nonatomic) BOOL isInMediaDownloadMode;

@property (weak, nonatomic) IBOutlet UIButton *showThumbnailButton;
@property (weak, nonatomic) IBOutlet UIButton *showPreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *showFullImageButton;
@property(nonatomic, strong) NSArray* mediaList;
@property(nonatomic, strong) DJIMedia* imageMedia;

@end

@implementation CameraFetchMediaViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isInMediaDownloadMode = NO;
    
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (!camera) {
        ShowResult(@"Cannot detect the camera. ");
        return;
    }
    
    if (![camera isMediaDownloadModeSupported]) {
        ShowResult(@"Media Download is not supported. ");
        return;
    }
    
    // start to check the pre-condition
    [self getCameraMode];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.mediaList) {
        self.mediaList = nil;
    }
    
    if (self.imageMedia) {
        self.imageMedia = nil;
    }
}

#pragma mark - Precondition
/**
 *  Check if the camera's mode is DJICameraModeMediaDownload.
 *  If the mode is not DJICameraModeMediaDownload, we need to set it to be DJICameraModeMediaDownload.
 */
-(void) getCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera getCameraModeWithCompletion:^(DJICameraMode mode, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: getCameraModeWithCompletion:. %@", error.description);
            }
            else if (mode != DJICameraModeMediaDownload) {
                [target setCameraMode];
            }
            else {
                [target startFetchMedia];
            }
        }];
    }
}

/**
 *  Set the camera's mode to DJICameraModeMediaDownload.
 */
-(void) setCameraMode {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera setCameraMode:DJICameraModeMediaDownload withCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: setCameraMode:withCompletion:. %@", error.description);
            }
            else {
                [target startFetchMedia];
            }
        }];
    }
}

#pragma mark - Actions
/**
 *  Get the list of media files from DJIMediaManager.
 */
-(void) startFetchMedia {
    __weak DJICamera* camera = [DemoComponentHelper fetchCamera];
    if (camera) {
        WeakRef(target);
        [camera.mediaManager fetchMediaListWithCompletion:^(NSArray<DJIMedia *> * _Nullable mediaList, NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: fetchMediaListWithCompletion:. %@", error.description);
            }
            else {
                target.mediaList = mediaList;
                ShowResult(@"SUCCESS: The media list is fetched. ");
            }
        }];
    }
}

/**
 *  In order to fetch the thumbnail, we can check if the thumbnail property is nil or not. 
 *  If it is nil, we need to call fetchThumbnailWithCompletion: before fetching the thumbnail.
 */
- (IBAction)onShowThumbnailButtonClicked:(id)sender {
    [self.showThumbnailButton setEnabled:NO];
    if (self.imageMedia.thumbnail == nil) {
        // fetch thumbnail is not invoked yet
        WeakRef(target);
        [self.imageMedia fetchThumbnailWithCompletion:^(NSError * _Nullable error) {
            WeakReturn(target);
            if (error) {
                ShowResult(@"ERROR: fetchThumbnailWithCompletion:. %@", error.description);
            }
            else {
                [target showPhotoWithImage:target.imageMedia.thumbnail];
            }
            [target.showThumbnailButton setEnabled:YES];
        }];
    }
}

/**
 *  Because the preview image is not as small as the thumbnail image, SDK would not cache it as 
 *  a property in DJIMedia. Instead, user need to decide whether to cache the image after invoking
 *  fetchPreviewImageWithCompletion:.
 */
- (IBAction)onShowPreviewButtonClicked:(id)sender {
    [self.showPreviewButton setEnabled:NO];
    WeakRef(target);
    [self.imageMedia fetchPreviewImageWithCompletion:^(UIImage *image, NSError * error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: fetchPreviewImageWithCompletion:%@", error);
        }
        else {
            [target showPhotoWithImage:image];
        }
        [target.showPreviewButton setEnabled:YES];
    }];
}

/**
 *  The full image is even larger than the preview image. A JPEG image is around 3mb to 4mb. Therefore, 
 *  SDK does not cache it. There are two differences between the process of fetching preview iamge and 
 *  the one of fetching full image: 
 *  1. The full image is received fully at once. The full image file is separated into several data packages. 
 *     The completion block will be called each time when a data package is ready. 
 *  2. The received data is the raw image file data rather than a UIImage object. It is more convenient to 
 *     store the file into disk.
 */
- (IBAction)onShowFullImageButtonClicked:(id)sender {
    [self.showFullImageButton setEnabled:NO];
    
    WeakRef(target);
    __block NSMutableData* downloadData = [[NSMutableData alloc] init];
    
    [self.imageMedia fetchMediaDataWithCompletion:^(NSData *data, BOOL *stop, NSError *error) {
        WeakReturn(target);
        if (error) {
            ShowResult(@"ERROR: fetchMediaDataWithCompletion:. %@", error.description);
            [self.showFullImageButton setEnabled:YES];
        }
        else {
            [downloadData appendData:data];
            if (downloadData.length == target.imageMedia.fileSizeInBytes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    WeakReturn(target);
                    [target showPhotoWithData:downloadData];
                    [self.showFullImageButton setEnabled:YES];
                });
            }
        }
        [self.showFullImageButton setEnabled:YES];
    }];
}

#pragma mark - UI related
-(void)setMediaList:(NSArray *)mediaList {
    _mediaList = mediaList;
    
    // Cache the first JPEG media file in the list.
    for (DJIMedia* media in self.mediaList) {
        if (media.mediaType == DJIMediaTypeJPEG) {
            self.imageMedia = media;
            break;
        }
    }
    
    if (self.imageMedia == nil) {
        ShowResult(@"There is no image media file in the SD card. ");
    }
    
    [self.showThumbnailButton setEnabled:(self.imageMedia != nil)];
    [self.showPreviewButton setEnabled:(self.imageMedia != nil)];
    [self.showFullImageButton setEnabled:(self.imageMedia != nil)];
}

// Utility methods to show the image
-(void) showPhotoWithImage:(UIImage*)image
{
    UIView* bkgndView = [[UIView alloc] initWithFrame:self.view.bounds];
    bkgndView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewTap:)];
    [bkgndView addGestureRecognizer:tapGesture];
    
    float width = image.size.width;
    float height = image.size.height;
    if (width > self.view.bounds.size.width * 0.7) {
        height = height*(self.view.bounds.size.width*0.7)/width;
        width = self.view.bounds.size.width*0.7;
    }
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

-(void) showPhotoWithData:(NSData*)data
{
    if (data) {
        UIImage* image = [UIImage imageWithData:data];
        if (image) {
            [self showPhotoWithImage:image];
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
