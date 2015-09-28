//
//  MediaTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-19.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

@class MediaLoadingManager;

@interface PhantomMediaTestViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DJIDroneDelegate, DJICameraDelegate>
{
    DJIDrone* _drone;
    DJIMediaManager* _mediaManager;
    MediaLoadingManager* _loadingManager;
    
    NSArray* _mediasList;
}

@property(nonatomic, assign) BOOL isFetchingMedias;
@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) UIActivityIndicatorView* loadingIndicator;

@end

typedef void (^MediaLoadingManagerTaskBlock)();

@interface MediaLoadingManager : NSObject {
    NSArray *_operationQueues;
    NSArray *_taskQueues;
    NSUInteger _imageThreads;
    NSUInteger _videoThreads;
    NSUInteger _mediaIndex;
}

- (id)initWithThreadsForImage:(NSUInteger)imageThreads threadsForVideo:(NSUInteger)videoThreads;

- (void)addTaskForMedia:(DJIMedia *)media withBlock:(MediaLoadingManagerTaskBlock)block;

- (void)cancelAllTasks;

@end