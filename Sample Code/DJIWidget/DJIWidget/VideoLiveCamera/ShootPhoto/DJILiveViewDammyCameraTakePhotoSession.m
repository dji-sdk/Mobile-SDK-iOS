//
//  DJILiveViewDammyCameraTakePhotoSession.m
//
//  Copyright (c) 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJILiveViewDammyCameraTakePhotoSession.h"
#import "DJILiveViewDammyCameraStructs.h"
#import <DJIWidget/DJIVideoPreviewer.h>
#import "DJIWidgetMacros.h"
#import "DJIAlbumHandler.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface DJILiveViewDammyCameraTakePhotoSession ()
@property(nonatomic, strong) DJIVideoPreviewer* previewer;
@property(nonatomic, strong) UIImage* captureResult;
@property(nonatomic, readwrite) DJILiveViewDammyCameraCaptureStatus captureStatus;
@property(nonatomic, strong) NSLock* statusLock;
@end

@implementation DJILiveViewDammyCameraTakePhotoSession

-(instancetype) _init
{
	self = [super init];
	return self;
}

-(instancetype) initWithVideoPreviewer:(DJIVideoPreviewer*)previewer
{
	self = [self _init];
	if (self) {
		_previewer = previewer;
		_captureStatus = DJILiveViewDammyCameraCaptureStatusNone;
		_statusLock = [NSLock new];
	}
	return self;
}

-(BOOL) startSession {
	[self.statusLock lock];
	if (self.captureStatus == DJILiveViewDammyCameraCaptureStatusCapturing) {
		[self.statusLock unlock];
		return NO;
	}
	self.captureStatus = DJILiveViewDammyCameraCaptureStatusCapturing;
	[self.statusLock unlock];
	
	//wait for timeout
	weakSelf(target);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[target timeout];
	});
	
	//capture
	[self.previewer snapshotPreview:^(UIImage *snapshot) {
		[target gotImage:snapshot];
	}];
	return YES;
}

-(BOOL) stopSession {
	[self.statusLock lock];
	if (self.captureStatus != DJILiveViewDammyCameraCaptureStatusCapturing) {
		[self.statusLock unlock];
		return NO;
	}
	self.captureStatus = DJILiveViewDammyCameraCaptureStatusEnded;
	[self.statusLock unlock];
	return YES;
}

-(void) asyncStopSession{
    weakSelf(target);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target stopSession];
    });
}

-(void) timeout{
	[self.statusLock lock];
    if (self.captureResult == nil
        && self.captureStatus == DJILiveViewDammyCameraCaptureStatusCapturing) {
		[self.statusLock unlock];
        [self stopSession];
    }
	[self.statusLock unlock];
}

-(void) gotImage:(UIImage*)image{
    //status check
	[self.statusLock lock];
    if (self.captureStatus != DJILiveViewDammyCameraCaptureStatusCapturing) {
		[self.statusLock unlock];
        return;
    }
	[self.statusLock unlock];
    
    self.captureResult = image;
    if (image) {
        
        //save to medialibrary
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSData* data = UIImagePNGRepresentation(image);
            if (!data) {
                [self asyncStopSession];
            }
            
            NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[self photoFileName]];
            NSURL* fileURL = [NSURL fileURLWithPath:path];
            [data writeToFile:path atomically:YES];
			
			[self.statusLock lock];
			if (self.captureStatus != DJILiveViewDammyCameraCaptureStatusCapturing) {
				[self.statusLock unlock];
				return;
			}
			[self.statusLock unlock];
            [DJIAlbumHandler savePhotoToAssetLibrary2:fileURL completionBlock:^(NSURL *assetURL,
                                                                                ALAsset* asset,
                                                                                NSError *error)
            {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self asyncStopSession];
				});
            }];
        });
    }
    else{
        [self asyncStopSession];
    }
}

+(NSString *)stringFromDate:(NSDate *)date{
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
	NSString *destDateString = [dateFormatter stringFromDate:date];
	return destDateString;
}

-(NSString*) photoFileName{
    return [[[self class] stringFromDate :[NSDate date]] stringByAppendingPathExtension:@"png"];
}

#pragma clang diagnostic pop

@end
