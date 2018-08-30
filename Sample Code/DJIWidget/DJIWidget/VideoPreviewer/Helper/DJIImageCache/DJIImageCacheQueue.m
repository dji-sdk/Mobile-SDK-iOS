//
//  DJIImageCacheQueue.m
//  DJIWidget
//
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIImageCacheQueue.h"
#import <pthread.h>

@interface DJIImageCacheQueue(){
    NSMutableArray* _queue;
    pthread_mutex_t _mutex;
    BOOL _threadSafe;
}
@end

@implementation DJIImageCacheQueue

-(void)dealloc{
    id cacheObject = nil;
    do{
        cacheObject = [self pull];
    } while(cacheObject != nil);
}

-(instancetype)init{
    if (self = [super init]){
        _threadSafe = YES;
        pthread_mutex_init(&_mutex, NULL);
        _queue = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithThreadSafe:(BOOL)threadSafe{
    if (self = [super init]){
        _threadSafe = threadSafe;
        if (_threadSafe){
            pthread_mutex_init(&_mutex, NULL);
        }
        _queue = [NSMutableArray array];
    }
    return self;
}

-(id)pull{
    if (_threadSafe){
        pthread_mutex_lock(&_mutex);
    }
    id cache = nil;
    if (_queue.count > 0){
        cache = _queue.firstObject;
        [_queue removeObjectAtIndex:0];
    }
    if (_threadSafe){
        pthread_mutex_unlock(&_mutex);
    }
    return cache;
}

-(BOOL)push:(id)cache{
    if (!cache){
        return NO;
    }
    if (_threadSafe){
        pthread_mutex_lock(&_mutex);
    }
    [_queue addObject:cache];
    if (_threadSafe){
        pthread_mutex_unlock(&_mutex);
    }
    return YES;
}

@end
